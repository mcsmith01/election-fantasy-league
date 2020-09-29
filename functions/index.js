const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.createUser = functions.auth.user().onCreate((user) => {
	return admin.database().ref(`players/${user.uid}/email`).set(user.email);
});

exports.deleteUser = functions.auth.user().onDelete((user) => {
	// TODO: Remove all predictions and league memberships from ACTIVE elections. Owned leagues will be ownerless (can keep owner as user)
	return admin.database().ref(`players/${user.uid}`).remove();
});

exports.deleteElection = functions.database.ref('/elections/{electionid}').onDelete((snapshot, context) => {
	const election = context.params.electionid;
	return admin.database().ref(`electionInfo/${election}`).remove();
});

exports.makePrediction = functions.https.onCall((data, context) => {
	const changeTime = (new Date()).toISOString();
	const player = context.auth.uid;
	const election = data.election;
	const race = data.race;
	const prediction = data.prediction;
	var type;
	var requestedLeagues = data.leagues || [];

	// TODO: Ensure that race is still open for predictions
	return admin.database().ref(`elections/${election}/races/${race}`).once('value')
	.then((raceSnap) => {
		const raceVal = raceSnap.val();
		type = raceVal['type'];
		const incumbents = raceVal['incumbency'];
		// Check to ensure that number of seats predicted is not more than number available
		const total = Object.values(incumbents).reduce((sum, value) => sum + value, 0);
		const predicted = Object.values(prediction).reduce((sum, value) => sum + value, 0);
		if (predicted > total) {
			console.log('Player: ' + player);
			console.log('Race: ' + race);
			console.log('Prediction: ' + prediction);
			throw new Error('Too many seats in prediction');
		}
		return admin.database().ref(`/players/${player}/elections/${election}`).once('value');
	})
	.then((playerSnap) => {
		const playerData = playerSnap.val() || {};
		const playerLeagues = playerData['leagues'] || {};

		if (playerData['predictions'] !== undefined) {
			var id = playerData['predictions'][race];
			if (id !== undefined) {
				// If there is already a prediction for this race, update it
				const ref = admin.database().ref(`elections/${election}/predictions/${id}`);
				ref.update({prediction: prediction});
				return ref;
			}
		}

		// Filter leagues by those that accept race type and membership approved
		var leagues = {};
		Object.keys(playerLeagues).forEach((leagueid) => {
			//TODO: raceTypes is now an array, use contains
			if (playerLeagues[leagueid]['member'] === true && playerLeagues[leagueid]['raceTypes'][type] !== undefined) {
				leagues[leagueid] = true;
			}
		});

		return admin.database().ref(`/elections/${election}/predictions`).push({
			owner: player,
			race: race,
			prediction: prediction,
			leagues: leagues,
			type: type
		});
	})
	.then((reference) => {
		var id = reference.key;
		console.log(`Prediction has id ${id}`);
		return admin.database().ref(`/players/${player}/elections/${election}/predictions/${race}`).set(id);
	});
});

exports.removePrediction = functions.database.ref('elections/{electionid}/predictions/{predictionid}').onDelete((snapshot, context) => {
	const election = context.params.electionid;
	const player = snapshot.val()['owner'];
	const race = snapshot.val()['race'];

	return admin.database().ref(`/players/${player}/elections/${election}/predictions/${race}`).remove();
});

exports.cleanPredictions = functions.https.onRequest((req, res) => {
	return admin.database().ref(`players`).once('value')
	.then((playerSnaps) => {
		playerSnaps.forEach((player) => {
			let elections = player.child('elections');
			elections.forEach((election) => {
				let predictions = election.child('predictions');
				predictions.forEach((prediction) => {
					cleanPrediction(election.key, player.key, prediction.key, prediction.val());
				});
			});
		});
		return res.status(200).send();
	});
});

function cleanPrediction(election, player, race, prediction) {
	return admin.database().ref(`elections/${election}/predictions/${prediction}`).once('value')
	.then((prediction) => {
		if (!prediction.exists()) {
			console.log('Removed prediction');
			return admin.database().ref(`players/${player}/elections/${election}/predictions/${race}`).remove();
		} else {
			return true;
		}
	})
}

exports.createLeague = functions.https.onCall((data, context) => {
	const owner = context.auth.uid;
	const leagueName = data.name;
	const election = data.election;
	const isOpen = data.isOpen;
	const raceTypes = data.races;
	var name;

	return admin.database().ref(`/players/${owner}/name`).once('value')
	.then((nameData) => {
		name = nameData.val();
		return admin.database().ref(`elections/${election}/leagueInfo`).push({
			'name': leagueName,
			'owner': {'id': owner, 'name': name},
			'isOpen': isOpen,
			'raceTypes': raceTypes,
			'members': 1
		});
	})
	.then((reference) => {
		return admin.database().ref(`elections/${election}/leagueData/${reference.key}/members/${owner}`).set({'name': name});
	});
});

exports.deleteLeague = functions.https.onCall((data, context) => {
	const caller = context.auth.uid;
	const league = data.league;
	const election = data.election;

	return admin.database().ref(`elections/${election}/leagueInfo/${league}`).once('value')
	.then((leagueSnap) => {
		const value = leagueSnap.val()
		const owner = value['owner']['id'];
		const name = value['name'];
		if (owner !== caller) {
			throw new Error('Attempt to delete league by other than the commissioner');
		}
		const alert = {'message': name + ' has been deleted', 'status': 2, 'time': (new Date()).toISOString()};
		leagueSnap.child('members').forEach((member) => {
			admin.database().ref(`players/${member.key}/elections/${election}/alerts`).push(alert);
		});
		return admin.database().ref(`elections/${election}/leagueInfo/${league}`).remove();
	})
	.then(() => {
		return admin.database().ref(`elections/${election}/leagueData/${league}`).remove();
	});
});

exports.joinLeague = functions.https.onCall((data, context) => {
	const player = context.auth.uid;
	const league = data.league;
	const election = data.election;
	var open;
	var leagueName;
	var playerName;
	return admin.database().ref(`elections/${election}/leagueInfo/${league}`).once('value')	
	.then((leagueSnap) => {
		open = leagueSnap.val()['isOpen'];
			leagueName = leagueSnap.val()['name'];
		return admin.database().ref(`players/${player}/name`).once('value')
	})
	.then((playerSnap) => {
		playerName = playerSnap.val();
		var location;
		if (open === true) {
			location = 'members';
		} else {
			location = 'pending';
		}	
		return admin.database().ref(`elections/${election}/leagueData/${league}/${location}/${player}`).set({'name': playerName});
	})
	.then(() => {
		var payload = {'time': (new Date()).toISOString()};
		if (open === true) {
			payload['message'] = 'You have joined ' + leagueName;
			payload['status'] = 0;
		} else {
			payload['message'] = 'Your application to join ' + leagueName + ' is pending';
			payload['status'] = 1;
		}
		return admin.database().ref(`players/${player}/elections/${election}/alerts`).push(payload);
	})
	.then(() => {
		return open;
	});
});

exports.acceptToLeague = functions.https.onCall((data, context) => {
	const caller = context.auth.uid;
	const league = data.league;
	const election = data.election;
	const player = data.player;
	var leagueName;
	var playerData;

	// Get information about league
	return admin.database().ref(`elections/${election}/leagueInfo/${league}`).once('value')
	.then((leagueSnap) => {
		// Verify that commissioner is one accepting
		if (leagueSnap.val()['owner']['id'] !== caller) {
			console.log('League: ' + league);
			console.log('Owner: ' + leagueSnap.val()['owner']['id']);
			console.log('Caller: ' + caller);
			throw new Error('Attempt to add player to league by other than the commissioner');
		}
		leagueName = leagueSnap.val()['name'];
		return admin.database().ref(`elections/${election}/leagueData/${league}/pending/${player}`).once('value');
	})
	.then((playerSnap) => {
		return admin.database().ref(`elections/${election}/leagueData/${league}/members/${player}`).set(playerSnap.val());
	})
	.then(() => {
		return admin.database().ref(`elections/${election}/leagueData/${league}/pending/${player}`).remove();
	})
	.then(() => {
		var payload = {'time': (new Date()).toISOString()};
		payload['message'] = 'Your application to join ' + leagueName + ' was accepted';
		payload['status'] = 0;
		return admin.database().ref(`players/${player}/elections/${election}/alerts`).push(payload);
	})
	.then(() => {
		return true;
	});
});

exports.removeFromLeague = functions.https.onCall((data, context) => {
	const caller = context.auth.uid;
	const league = data.league;
	const election = data.election;
	const player = data.player;
	var leagueName;

	return admin.database().ref(`elections/${election}/leagueInfo/${league}`).once('value')
	.then((leagueSnap) => {
		var data = leagueSnap.val();
		if (data['owner']['id'] !== caller && caller !== player) {
			console.log('League: ' + league);
			console.log('Player: ' + player);
			console.log('Owner: ' + data['owner']);
			console.log('Caller: ' + caller);
			throw new Error('Attempt to remove player from league by other than self or the commissioner');
		}
		leagueName = data['name'];
		return admin.database().ref(`players/${player}/elections/${election}/leagues/${league}/member`).once('value');
	})
	.then((member) => {
		isMember = member.val();
		if (isMember === true) {
			return admin.database().ref(`elections/${election}/leagueData/${league}/members/${player}`).remove();
		} else {
			return admin.database().ref(`elections/${election}/leagueData/${league}/pending/${player}`).remove();
		}
	})
	.then(() => {
		var payload = {'time': (new Date()).toISOString()};
		if (caller === player) {
			payload['status'] = 0;
			if (isMember === true) {
				payload['message'] = 'You have left ' + leagueName;
			} else {
				payload['message'] = 'You removed your application to join ' + leagueName;
			}
		} else {
			payload['status'] = 2;
			if (isMember === true) {
				payload['message'] = 'You have been removed from ' + leagueName;
			} else {
				payload['message'] = 'Your application to join ' + leagueName + ' was denied';
			}
		}
		return admin.database().ref(`players/${player}/elections/${election}/alerts`).push(payload);		
	})
	.then(() => {
		return true;
	});
});

exports.joinedLeague = functions.database.ref('elections/{electionid}/leagueData/{leagueid}/members/{playerid}').onCreate((snapshot, context) => {
	const election = context.params.electionid;
	const league = context.params.leagueid;
	const player = context.params.playerid;
	var playerName;
	var types;

	return admin.database().ref(`players/${player}/name`).once('value')
	.then((name) => {
		playerName = name.val();
		return admin.database().ref(`elections/${election}/leagueInfo/${league}/name`).once('value');
	})
	.then((name) => {
		let leagueName = name.val();
		sendMessage("League News", `${playerName} has joined ${leagueName}`, league);
		return admin.database().ref(`elections/${election}/leagueInfo/${league}/raceTypes`).once('value')
	})
	.then((typeSnap) => {
		types = typeSnap.val();
		return admin.database().ref(`elections/${election}/predictions/`).orderByChild('owner').equalTo(player).once('value');
	})
	.then((predictions) => {
		predictions.forEach((prediction) => {
			const type = prediction.val()['type'];
			// If the prediction is of a type that the league supports, add the league to the prediction
			if (types.includes(type)) {
				prediction.ref.child('leagues').child(league).set(true);
			}
		});
		return admin.database().ref(`players/${player}/elections/${election}/leagues/${league}`).set({'member': true, 'raceTypes': types});
	});
});

exports.leftLeague = functions.database.ref('elections/{electionid}/leagueData/{leagueid}/members/{playerid}').onDelete((snapshot, context) => {
	const election = context.params.electionid;
	const league = context.params.leagueid;
	const player = context.params.playerid;

	return admin.database().ref(`players/${player}/elections/${election}/leagues/${league}`).remove()
	.then(() => {
		return admin.database().ref(`players/${player}/name`).once('value');
	})
	.then((name) => {
		playerName = name.val();
		return admin.database().ref(`elections/${election}/leagueInfo/${league}/name`).once('value');
	})
	.then((name) => {
		let leagueName = name.val();
		sendMessage("League News", `${playerName} has left ${leagueName}`, league);
		return admin.database().ref(`elections/${election}/predictions/`).orderByChild('owner').equalTo(player).once('value');
	})
	.then((predictions) => {
		predictions.forEach((prediction) => {
			prediction.ref.child('leagues').child(league).remove();
		});
		return true;
	});
});

exports.leagueMembershipChanged = functions.database.ref('elections/{electionid}/leagueData/{leagueid}/members').onWrite((change, context) => {
	const election = context.params.electionid;
	const league = context.params.leagueid;

	if (change.after.exists()) {
		return admin.database().ref(`elections/${election}/leagueInfo/${league}/members`).set(change.after.numChildren());		
	} else {
		return true;
	}
});

exports.appliedToLeague = functions.database.ref('elections/{electionid}/leagueData/{leagueid}/pending/{playerid}').onWrite((change, context) => {
	const election = context.params.electionid;
	const league = context.params.leagueid;
	const player = context.params.playerid;
	var playerName;
	var leagueName;

	if (change.after.exists()) {
		return admin.database().ref(`players/${player}/name`).once('value')
		.then((name) => {
			playerName = name.val();
			return admin.database().ref(`elections/${election}/leagueInfo/${league}/name`).once('value');
		})
		.then((name) => {
			let leagueName = name.val();
			sendMessage("League Application", `${playerName} has requested to join ${leagueName}`, `${league}-owner`);
			return admin.database().ref(`players/${player}/elections/${election}/leagues/${league}`).set({'member': false})
		});
	} else {
		return admin.database().ref(`players/${player}/elections/${election}/leagues/${league}`).remove();
	}
});

exports.changedName = functions.database.ref('players/{playerid}/name').onUpdate((change, context) => {
	const player = context.params.playerid;
	const newName = change.after.val()
	return admin.database().ref(`players/${player}/elections`).once('value')
	.then((electionsSnap) => {
		electionsSnap.forEach((electionSnap) => {
			electionSnap.child('leagues').forEach((league) => {
				admin.database().ref(`elections/${electionSnap.key}/leagues/${league.key}/members/${player}/name`).set(newName);
			});
		});
		return true;
	});
})

exports.callRace = functions.https.onCall((data, context) => {
	// TODO: Verify as admin
	// TODO: Keep ranking of all players
	const election = data.election;
	const race = data.raceid;
	const results = data.results;
	var leagueScores = {};
	const possible = Object.values(results).reduce((sum, value) => sum + value, 0);
	// console.log('Total seats ' + possible);
	//TODO: Verify possible === total seats
	return admin.database().ref(`elections/${election}/predictions`).orderByChild('race').equalTo(race).once('value')
	.then((predictions) => {
		// Score each prediction
		var predictionScores = {};
		var totalScores = 0;
		predictions.forEach((prediction) => {
			const val = prediction.val();
			const owner = val['owner'];
			const assertion = val['prediction'];
			const leagues = val['leagues'] || [];
			var score = 0;
			// Calculate number of correct guesses
			Object.keys(results).forEach((result) => {
				const guess = assertion[result] || 0;
				score += Math.min(guess, results[result]);
			});
			score = score / possible;
			predictionScores[prediction.key] = score;
			totalScores += score;
			// Add score to each league for this prediction
			Object.keys(leagues).forEach((league) => {
				if (leagueScores[league] === undefined) {
					leagueScores[league] = {};
				}
				leagueScores[league][owner] = score;
			});
		});
		// apportion is how much to multiply score by; fewer good predictions, higher apportion
		var apportion = 0;
		var successRate = 0;
		// if totalScores > 0, then predictions.numChildren() > 0
		if (totalScores > 0) {
			apportion = predictions.numChildren() / totalScores;
			successRate = totalScores / predictions.numChildren();
		}

		// Update each prediction with accuracy and weighted score
		Object.keys(predictionScores).forEach((prediction) => {
			const score = predictionScores[prediction];
			admin.database().ref(`elections/${election}/predictions/${prediction}`).update({
				'accuracy': score,
				'score': score * apportion
			});
			admin.database().ref(`elections/${election}/scores/`)	
		});
		return admin.database().ref(`elections/${election}/races/${race}/successRate`).set(successRate);
	})
	.then(() => {
		// Update each league's data with scores
		Object.keys(leagueScores).forEach((leagueID) => {
			scoreLeague(election, leagueID, leagueScores[leagueID], race);
		});
		return admin.database().ref(`elections/${election}/races/${race}/results`).set(results);
	});
});

function scoreLeague(election, leagueID, leagueScores, race) {
	return admin.database().ref(`elections/${election}/leagueData/${leagueID}/members`).once('value')
	.then((membersSnap) => {
		const memberCount = membersSnap.numChildren();
		const totalScore = Object.values(leagueScores).reduce((sum, value) => sum + value, 0);
		var apportion = 0;
		if (totalScore > 0) {
			apportion = memberCount / totalScore;
		}
		var scores = {};
		Object.keys(leagueScores).forEach((member) => {
			scores[member] = leagueScores[member] * apportion;
		});
		// TODO: What structure makes the most sense for scores?
		return admin.database().ref(`elections/${election}/leagueData/${leagueID}/scores/${race}`).set(scores);
	});
}


exports.resetElection = functions.https.onCall((data, context) => {
	const election = data.election;
	return admin.database().ref(`elections/${election}/races`).orderByChild('successRate').startAt(0).once('value')
	.then((snapshot) => {
		snapshot.forEach((race) => {
			race.child('successRate').ref.remove();
			race.child('results').ref.remove();
		});
		return true;
	});
})

exports.resultsCancelled = functions.database.ref('elections/{electionid}/races/{raceid}/results').onDelete((snapshot, context) => {
	const election = context.params.electionid;
	const race = context.params.raceid;
	return admin.database().ref(`elections/${election}/predictions`).orderByChild('race').equalTo(race).once('value')
	.then((predictionSnap) => {
		predictionSnap.forEach((prediction) => {
			prediction.child('score').ref.remove();
			prediction.child('accuracy').ref.remove();
		});
		return admin.database().ref(`elections/${election}/leagueData`).once('value');
	})
	.then((leagueSnap) => {
		leagueSnap.forEach((league) => {
			if (league.child('scores').child(race).exists()) {
				league.child('scores').child(race).ref.remove();
			}
		});
		return true;
	})
});

exports.sendMessage = functions.https.onCall((data, context) => {
	const title = data.title;
	const body = data.body;

	sendMessage(title, body, 'all');
});

exports.deleteUsers = functions.https.onRequest((req, res) => {
	//deleteAllUsers();
	res.status(503).send();
});

function deleteAllUsers(nextPageToken) {
	// List batch of users, 1000 at a time.
	admin.auth().listUsers(1000, nextPageToken)
    .then((listUsersResult) => {
    	listUsersResult.users.forEach((userRecord) => {
    		admin.auth().deleteUser(userRecord.uid);
    	});
    	if (listUsersResult.pageToken) {
    		// List next batch of users.
    		return deleteAllUsers(listUsersResult.pageToken);
    	} else {
    		return true;
    	}
    })
    .catch((error) => {
    	console.log('Error deleting users:', error);
    });
}

function sendMessage(title, body, topic) {
	var message = {
		notification: {
			'title': title,
			'body': body
		},
		'topic': topic
	}
	admin.messaging().send(message)
	.then((response) => {
		return true;
	})
	.catch((error) => {
		console.log('Error sending message:', error);
	});
}
