AdminUser.create!(username: 'admin', email: 'admin@example.com', password: 'password', password_confirmation: 'password')

user = User.create(email: 'email1@foo.com', birthday: '2.5.1993', username: 'marvin',
        password: 'secret', password_confirmation: 'secret', tos: "true", credits: 500)

user_2 = User.create(email: 'milva@example.com', birthday: '12.10.1995', username: 'milva',
        password: 'secret', password_confirmation: 'secret', tos: "true", credits: 500)



game = Game.create(title: "entdecke deinen kiez", description: "deine aufgabe wird es sein ein paar photos deiner umgebung zu sammeln",
    short_description: "kiez entdecken", time_limit: nil, costs: 5, author: user)

game_1 = Game.create(title: "Guerilla-Guardening", description: "Du bringst Pflanzen dorthin, wo sie niemand erwartet. In Untergrund-Kreisen nennt man das Ganze Guerllia-Gardening. Dabei?", time_limit: 0, costs: 0, short_description: "Mach das grau bunt! Und versetze Leute, die an dein...")
game_1.tasks << PhotoTask.create(title: "Guerilla-Pflanzer", description: "Nimm dir einen alten Fahrradkorb, eine Bananenkiste, einen kleinen Eimer oder irgendeinen Behaelter, den du nicht brauchst und der sich gut mit Draht oder am Henkel irgendwo aufhaengen laesst. \r\nBefuelle ihn mit Erde und pflanze ein paar Blumen rein. Blumen findest du beim Blumenhaendler in deiner Naehe.\r\nSuche dir jetzt einen besonders tristen Ort aus, an dem aber taeglich viele Menschen vorbeigehen. Haenge dort deinen kleinen Garten auf. ",
    type: "PhotoTask", question: "Fotografiere deinen Mini-Garten und lade das Foto hier hoch!", short_description: "Guerilla-Pflanzer", position: 1)


game_2 = Game.create(title: "Mach deinen Kiez gruener", description: "Planze mindestens fuenf neue Pflanzen in deiner Umgebung",
    short_description: "Kiez gruener machen", time_limit: nil, costs: 5, author: user)
game_2.tasks.create(title: 'Pflanze deine Polizeistation', type: 'QuestionTask')
game_2.tasks.create(title: 'Pflanzen vor deiner Schule', type: 'QuestionTask', timeout_secs: 300)



game_3 = Game.create(title: "Der Ursprung von Weihnachten", description: "Warum feiern wir eigentlich Weihnachten? Lese dir die Weihnachtsgeschichte durch und beantworte im Anschluss die Fragen.", time_limit: 0, costs: 0, short_description: "Der Ursprung von Weihnachten...")


game_3.tasks << MultipleChoiceTask.create(title: "Im Christentum wird Weihnachten gefeiert, aber wie sieht es eigentlich in den andern Religionen aus?", description: "Nimm dir einen alten Fahrradkorb, eine Bananenkiste, einen kleinen Eimer oder irgendeinen Behaelter, den du nicht brauchst und der sich gut mit Draht oder am Henkel irgendwo aufhaengen laesst. \r\nBefuelle ihn mit Erde und pflanze ein paar Blumen rein. Blumen findest du beim Blumenhaendler in deiner Naehe.\r\nSuche dir jetzt einen besonders tristen Ort aus, an dem aber taeglich viele Menschen vorbeigehen. Haenge dort deinen kleinen Garten auf. ",
    type: "MultipleChoiceTask", short_description: "Weihnachtsquiz", position: 1, minimum_score: 6,
            questions: [{
        question: "If a=1, b=2. What is a+b?",
        points: 1,
        options: [
          { answer: "12", check: false },
          { answer: "3", check: true },
          { answer: "4", check: false },
        ]
      },{
        question: "Ruby ia a",
        points: 5,
        options: [
          { answer: "dynamic language", check: true },
          { answer: "cool", check: true },
          { answer: "none of the above", check: false },
        ]
      },{
        question: "Consider the following:\n  \n    I. An eight-by-eight chessboard.\n   II. An eight-by-eight chessboard with two opposite corners removed.\n  III. An eight-by-eight chessboard with all four corners removed.\n\nWhich of these can be tiled by two-by-one dominoes (with no overlaps or gaps, and every domino contained within the board)?",
        points: 10,
        options: [
          { answer: "I only", check: false },
          { answer: "I and II only", check: false },
          { answer: "I and III only", check: true },
        ]
      }])


mission = Mission.create(start_points: 10, games: [game, game_1, game_2, game_3])

badge = Badge.create(title: 'ultimate badge')
# associate badge with game
