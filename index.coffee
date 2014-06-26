config_gerritUserAndHost = 'sebastian@review.typo3.org'
config_limit = 5

GerritEventEmitter = require('gerrit-event-emitter').GerritEventEmitter
gerritEventEmitter = new GerritEventEmitter(config_gerritUserAndHost, 29418, true)
exec = require('child_process').exec

gerritEventEmitter.on('patchsetCreated', (eventData) ->
	console.log("Patchset created")
	console.log(eventData)
	if parseInt(eventData.patchSet.number) != 1
		# we only want to work on new changes.
		console.log("Early Return")
		# return


	# TODO: filter by eventData.change.project


	username = eventData.change.owner.username
	fetchUserMetadata(username, communicateWithUser)
)

# Return total number of changes (up to config_limit) and last change
fetchUserMetadata = (username, callback) ->
	# TODO!!! SANITIZE USERNAME (so that it only contains SANE (numbers/letters/_/- or so) characters!!!!)
	projectQuery = "( project:Packages/TYPO3.Neos OR project:Packages/TYPO3.Neos.NodeTypes )"
	exec("ssh -p 29418 #{config_gerritUserAndHost} gerrit query --format=JSON 'owner:#{username} AND #{projectQuery} limit:#{config_limit}'",
		(error, stdout, stderr) ->
			#console.log('stdout: ' + stdout)
			#console.log('stderr: ' + stderr)
			if error != null
				console.log('exec error: ' + error)
				console.log('exec error: ' + stderr)

			changeLines = stdout.trim().split('\n')
			# one change per line, and at the end one additional "stats" line.
			numberOfChanges = changeLines.length - 1

			if numberOfChanges == 0
				# do nothing, should not happen.
				return

			name = JSON.parse(changeLines[0]).owner.name || username

			if numberOfChanges == 1
				callback(name, numberOfChanges)
			else
				# we now look into the *second* change, as the first one is the current one which was pushed "now"
				dateOfLastChange = JSON.parse(changeLines[1]).lastUpdated
				callback(name, numberOfChanges, dateOfLastChange)
	)


communicateWithUser = (name, numberOfChanges, lastCommit) ->
	currentTimestamp = new Date().getTime() / 1000

	# TODO: split name, to extract first name!

	text = null

	if numberOfChanges == 1
		text = """
Hi #{name},

a very warm welcome to review.typo3.org. We, the Neos and Flow team, are glad that you chose to
contribute and .....

Kind Regards,
your TYPO3 Neos Team!
PS: If you need any help, please send us an e-mail at neos@typo3.org or use irc.freenode.net #typo3-coreteam
"""

	else if numberOfChanges == 10
		text = """
Hi #{name},

Congratulations for your 10th code contribution! Keep up the good work :-)

Kind Regards,
your TYPO3 Neos Team!
PS: Did you consider to join one of our code sprints yet?
"""

	else if numberOfChanges == 25
		text = """
Hi #{name},

Congratulations for your 25th change to TYPO3 Neos and Flow. You Rock!

Kind Regards,
your TYPO3 Neos Team!
"""

	else if numberOfChanges == 50
		text = """
Hi #{name},

Congratulations for your 50th change to TYPO3 Neos and Flow. You are a Neos Jedi!

Kind Regards,
your TYPO3 Neos Team!
"""

	else if numberOfChanges > 1 && (currentTimestamp - lastCommit) > 60*60*24 * 30 * 3
		# longer than 3 months absence
		text = """
Hi #{name},

we missed you and are glad you are back contibuting to TYPO3 Neos and Flow!

Kind Regards,
your TYPO3 Neos Team!
PS: If you need any help, please send us an e-mail at neos@typo3.org or use irc.freenode.net #typo3-coreteam
"""


	if text

		# gerrit review command



sendMessageToChange = (change, message) ->
	# ssh

	exec("ssh -p 29418 #{config_gerritUserAndHost} gerrit review TODO ",
	(error, stdout, stderr) ->
		#console.log('stdout: ' + stdout)
		#console.log('stderr: ' + stderr)
		if error != null
			console.log('exec error: ' + error)
			console.log('exec error: ' + stderr)
	)

fetchUserMetadata("fheinze", communicateWithUser)
fetchUserMetadata("sebastian", communicateWithUser)
gerritEventEmitter.start() # start gerrit-stream process.


# Quotes or Sprüche
messages =
	"High Five!"
	"Thank you, buddy!"
	"Furcht ist der Weg zur dunklen Seite."
	"If you are on a T3CON, don't forget to bring a towel."
	"Ready for takeoff."
	"A small step for you, a big step for mankind."
	"Yiihaaaa!"
	# Für Risiken und Nebenwirkungen ...
	"Warning: The TYPO3 Community is highly addictive."
	"Tschagga"
	# Code Yoda sprüche
	"Code Review You Must."


	# für große Commits
	"Big Daddy's in the House"

	# um Weihnachten herum
	"Merry Christmas!"
	"Happy Easter!"
	"We Love Code -- Happy Valentine's Day!"
	""