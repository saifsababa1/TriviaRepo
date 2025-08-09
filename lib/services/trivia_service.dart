import 'dart:math';
import '../models/trivia_question.dart';

class TriviaService {
  static final TriviaService _instance = TriviaService._internal();
  factory TriviaService() => _instance;
  TriviaService._internal();

  final Random _random = Random();

  // Web-safe shuffle implementation using List.from and removeAt
  List<T> _shuffleList<T>(List<T> list) {
    final shuffled = <T>[];
    final temp = List<T>.from(list); // Create mutable copy

    while (temp.isNotEmpty) {
      final randomIndex = _random.nextInt(temp.length);
      shuffled.add(temp.removeAt(randomIndex));
    }

    return shuffled;
  }

  // Comprehensive trivia questions database
  static const List<Map<String, dynamic>> _triviaDatabase = [
    // Science Questions
    {
      'id': 'sci_001',
      'question': 'What is the chemical symbol for gold?',
      'options': ['Go', 'Gd', 'Au', 'Ag'],
      'correctAnswerIndex': 2,
      'category': 'Science',
      'difficulty': 'Easy',
      'explanation': 'Au comes from the Latin word "aurum" meaning gold.',
      'points': 10,
    },
    {
      'id': 'sci_002',
      'question': 'Which planet is known as the Red Planet?',
      'options': ['Venus', 'Mars', 'Jupiter', 'Saturn'],
      'correctAnswerIndex': 1,
      'category': 'Science',
      'difficulty': 'Easy',
      'explanation':
          'Mars appears red due to iron oxide (rust) on its surface.',
      'points': 10,
    },
    {
      'id': 'sci_003',
      'question': 'What is the speed of light in vacuum?',
      'options': [
        '300,000 km/s',
        '299,792,458 m/s',
        '186,000 miles/s',
        'All of the above',
      ],
      'correctAnswerIndex': 3,
      'category': 'Science',
      'difficulty': 'Medium',
      'explanation':
          'The speed of light is approximately 299,792,458 meters per second.',
      'points': 20,
    },
    {
      'id': 'sci_004',
      'question': 'What is the largest organ in the human body?',
      'options': ['Liver', 'Brain', 'Skin', 'Heart'],
      'correctAnswerIndex': 2,
      'category': 'Science',
      'difficulty': 'Easy',
      'explanation': 'The skin is the largest organ, covering the entire body.',
      'points': 10,
    },
    {
      'id': 'sci_005',
      'question': 'What is the most abundant gas in Earth\'s atmosphere?',
      'options': ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Argon'],
      'correctAnswerIndex': 2,
      'category': 'Science',
      'difficulty': 'Medium',
      'explanation': 'Nitrogen makes up about 78% of Earth\'s atmosphere.',
      'points': 20,
    },

    // History Questions
    {
      'id': 'hist_001',
      'question': 'In which year did World War II end?',
      'options': ['1944', '1945', '1946', '1947'],
      'correctAnswerIndex': 1,
      'category': 'History',
      'difficulty': 'Easy',
      'explanation':
          'World War II ended in 1945 with Japan\'s surrender in September.',
      'points': 10,
    },
    {
      'id': 'hist_002',
      'question': 'Who was the first person to walk on the moon?',
      'options': [
        'Buzz Aldrin',
        'Neil Armstrong',
        'John Glenn',
        'Alan Shepard',
      ],
      'correctAnswerIndex': 1,
      'category': 'History',
      'difficulty': 'Easy',
      'explanation':
          'Neil Armstrong was the first human to step on the Moon on July 20, 1969.',
      'points': 10,
    },
    {
      'id': 'hist_003',
      'question':
          'Which ancient wonder of the world was located in Alexandria?',
      'options': [
        'Colossus of Rhodes',
        'Lighthouse of Alexandria',
        'Hanging Gardens',
        'Temple of Artemis',
      ],
      'correctAnswerIndex': 1,
      'category': 'History',
      'difficulty': 'Medium',
      'explanation':
          'The Lighthouse of Alexandria was one of the Seven Wonders of the Ancient World.',
      'points': 20,
    },
    {
      'id': 'hist_004',
      'question': 'What year did the Berlin Wall fall?',
      'options': ['1987', '1988', '1989', '1990'],
      'correctAnswerIndex': 2,
      'category': 'History',
      'difficulty': 'Medium',
      'explanation': 'The Berlin Wall fell on November 9, 1989.',
      'points': 20,
    },
    {
      'id': 'hist_005',
      'question': 'Who was the first President of the United States?',
      'options': [
        'Thomas Jefferson',
        'George Washington',
        'John Adams',
        'Benjamin Franklin',
      ],
      'correctAnswerIndex': 1,
      'category': 'History',
      'difficulty': 'Easy',
      'explanation':
          'George Washington served as the first President from 1789 to 1797.',
      'points': 10,
    },

    // Geography Questions
    {
      'id': 'geo_001',
      'question': 'What is the capital of Australia?',
      'options': ['Sydney', 'Melbourne', 'Canberra', 'Perth'],
      'correctAnswerIndex': 2,
      'category': 'Geography',
      'difficulty': 'Medium',
      'explanation':
          'Canberra is the capital city of Australia, not Sydney or Melbourne.',
      'points': 20,
    },
    {
      'id': 'geo_002',
      'question': 'Which is the longest river in the world?',
      'options': [
        'Amazon River',
        'Nile River',
        'Yangtze River',
        'Mississippi River',
      ],
      'correctAnswerIndex': 1,
      'category': 'Geography',
      'difficulty': 'Easy',
      'explanation': 'The Nile River is approximately 6,650 km long.',
      'points': 10,
    },
    {
      'id': 'geo_003',
      'question': 'How many continents are there?',
      'options': ['5', '6', '7', '8'],
      'correctAnswerIndex': 2,
      'category': 'Geography',
      'difficulty': 'Easy',
      'explanation':
          'There are 7 continents: Asia, Africa, North America, South America, Antarctica, Europe, and Australia.',
      'points': 10,
    },
    {
      'id': 'geo_004',
      'question': 'Which mountain range contains Mount Everest?',
      'options': ['Alps', 'Himalayas', 'Andes', 'Rocky Mountains'],
      'correctAnswerIndex': 1,
      'category': 'Geography',
      'difficulty': 'Easy',
      'explanation':
          'Mount Everest is located in the Himalayas on the border between Nepal and Tibet.',
      'points': 10,
    },
    {
      'id': 'geo_005',
      'question': 'What is the smallest country in the world?',
      'options': ['Monaco', 'San Marino', 'Vatican City', 'Liechtenstein'],
      'correctAnswerIndex': 2,
      'category': 'Geography',
      'difficulty': 'Medium',
      'explanation':
          'Vatican City is the smallest sovereign state with an area of 0.17 square miles.',
      'points': 20,
    },

    // Sports Questions
    {
      'id': 'sport_001',
      'question':
          'How many players are on a basketball team on the court at one time?',
      'options': ['4', '5', '6', '7'],
      'correctAnswerIndex': 1,
      'category': 'Sports',
      'difficulty': 'Easy',
      'explanation':
          'Each basketball team has 5 players on the court at any given time.',
      'points': 10,
    },
    {
      'id': 'sport_002',
      'question': 'In which sport would you perform a slam dunk?',
      'options': ['Tennis', 'Basketball', 'Volleyball', 'Soccer'],
      'correctAnswerIndex': 1,
      'category': 'Sports',
      'difficulty': 'Easy',
      'explanation':
          'A slam dunk is a basketball shot where the player jumps and scores by putting the ball directly through the basket.',
      'points': 10,
    },
    {
      'id': 'sport_003',
      'question': 'How often are the Summer Olympic Games held?',
      'options': [
        'Every 2 years',
        'Every 3 years',
        'Every 4 years',
        'Every 5 years',
      ],
      'correctAnswerIndex': 2,
      'category': 'Sports',
      'difficulty': 'Easy',
      'explanation': 'The Summer Olympic Games are held every 4 years.',
      'points': 10,
    },
    {
      'id': 'sport_004',
      'question': 'What is the maximum score possible in ten-pin bowling?',
      'options': ['250', '280', '300', '350'],
      'correctAnswerIndex': 2,
      'category': 'Sports',
      'difficulty': 'Medium',
      'explanation':
          'A perfect game in bowling consists of 12 strikes for a total score of 300.',
      'points': 20,
    },
    {
      'id': 'sport_005',
      'question': 'In golf, what is one stroke under par called?',
      'options': ['Birdie', 'Eagle', 'Albatross', 'Bogey'],
      'correctAnswerIndex': 0,
      'category': 'Sports',
      'difficulty': 'Medium',
      'explanation': 'A birdie is a score of one stroke under par on a hole.',
      'points': 20,
    },

    // Entertainment Questions
    {
      'id': 'ent_001',
      'question': 'Which movie won the Academy Award for Best Picture in 2020?',
      'options': ['1917', 'Joker', 'Parasite', 'Once Upon a Time in Hollywood'],
      'correctAnswerIndex': 2,
      'category': 'Entertainment',
      'difficulty': 'Medium',
      'explanation':
          'Parasite became the first non-English film to win Best Picture.',
      'points': 20,
    },
    {
      'id': 'ent_002',
      'question': 'Who composed the music for the movie "Star Wars"?',
      'options': [
        'Hans Zimmer',
        'John Williams',
        'Danny Elfman',
        'Alan Silvestri',
      ],
      'correctAnswerIndex': 1,
      'category': 'Entertainment',
      'difficulty': 'Easy',
      'explanation':
          'John Williams composed the iconic Star Wars musical score.',
      'points': 10,
    },
    {
      'id': 'ent_003',
      'question':
          'Which streaming platform created the series "Stranger Things"?',
      'options': ['Amazon Prime', 'Hulu', 'Netflix', 'Disney+'],
      'correctAnswerIndex': 2,
      'category': 'Entertainment',
      'difficulty': 'Easy',
      'explanation': 'Stranger Things is a Netflix original series.',
      'points': 10,
    },
    {
      'id': 'ent_004',
      'question': 'What is the highest-grossing film of all time?',
      'options': [
        'Titanic',
        'Avatar',
        'Avengers: Endgame',
        'Star Wars: The Force Awakens',
      ],
      'correctAnswerIndex': 1,
      'category': 'Entertainment',
      'difficulty': 'Medium',
      'explanation':
          'Avatar (2009) is the highest-grossing film with over \$2.8 billion worldwide.',
      'points': 20,
    },
    {
      'id': 'ent_005',
      'question': 'Which Beatles album features the song "Here Comes the Sun"?',
      'options': [
        'Abbey Road',
        'Sgt. Pepper\'s',
        'Revolver',
        'The White Album',
      ],
      'correctAnswerIndex': 0,
      'category': 'Entertainment',
      'difficulty': 'Hard',
      'explanation':
          '"Here Comes the Sun" is on the Abbey Road album, written by George Harrison.',
      'points': 30,
    },

    // Technology Questions
    {
      'id': 'tech_001',
      'question': 'What does "HTTP" stand for?',
      'options': [
        'HyperText Transfer Protocol',
        'High Tech Transfer Protocol',
        'HyperText Technical Protocol',
        'High Transfer Text Protocol',
      ],
      'correctAnswerIndex': 0,
      'category': 'Technology',
      'difficulty': 'Medium',
      'explanation':
          'HTTP stands for HyperText Transfer Protocol, used for web communication.',
      'points': 20,
    },
    {
      'id': 'tech_002',
      'question': 'Who founded Microsoft?',
      'options': ['Steve Jobs', 'Bill Gates', 'Mark Zuckerberg', 'Larry Page'],
      'correctAnswerIndex': 1,
      'category': 'Technology',
      'difficulty': 'Easy',
      'explanation': 'Bill Gates co-founded Microsoft with Paul Allen in 1975.',
      'points': 10,
    },
    {
      'id': 'tech_003',
      'question': 'What year was the first iPhone released?',
      'options': ['2005', '2006', '2007', '2008'],
      'correctAnswerIndex': 2,
      'category': 'Technology',
      'difficulty': 'Easy',
      'explanation': 'The first iPhone was released by Apple on June 29, 2007.',
      'points': 10,
    },
    {
      'id': 'tech_004',
      'question': 'What does "AI" stand for in technology?',
      'options': [
        'Automatic Intelligence',
        'Artificial Intelligence',
        'Advanced Intelligence',
        'Applied Intelligence',
      ],
      'correctAnswerIndex': 1,
      'category': 'Technology',
      'difficulty': 'Easy',
      'explanation': 'AI stands for Artificial Intelligence.',
      'points': 10,
    },
    {
      'id': 'tech_005',
      'question':
          'Which programming language is known as the "language of the web"?',
      'options': ['Python', 'Java', 'JavaScript', 'C++'],
      'correctAnswerIndex': 2,
      'category': 'Technology',
      'difficulty': 'Medium',
      'explanation':
          'JavaScript is primarily used for web development and is often called the language of the web.',
      'points': 20,
    },

    // Literature Questions
    {
      'id': 'lit_001',
      'question': 'Who wrote the novel "Pride and Prejudice"?',
      'options': [
        'Charlotte Brontë',
        'Jane Austen',
        'Emily Dickinson',
        'Virginia Woolf',
      ],
      'correctAnswerIndex': 1,
      'category': 'Literature',
      'difficulty': 'Easy',
      'explanation': 'Jane Austen published Pride and Prejudice in 1813.',
      'points': 10,
    },
    {
      'id': 'lit_002',
      'question':
          'Which Shakespeare play features the characters Romeo and Juliet?',
      'options': ['Hamlet', 'Macbeth', 'Romeo and Juliet', 'Othello'],
      'correctAnswerIndex': 2,
      'category': 'Literature',
      'difficulty': 'Easy',
      'explanation':
          'Romeo and Juliet is one of Shakespeare\'s most famous tragedies.',
      'points': 10,
    },
    {
      'id': 'lit_003',
      'question': 'Who wrote "1984"?',
      'options': [
        'Aldous Huxley',
        'George Orwell',
        'Ray Bradbury',
        'Kurt Vonnegut',
      ],
      'correctAnswerIndex': 1,
      'category': 'Literature',
      'difficulty': 'Easy',
      'explanation':
          'George Orwell wrote the dystopian novel "1984" published in 1949.',
      'points': 10,
    },
    {
      'id': 'lit_004',
      'question': 'What is the first book in the Harry Potter series?',
      'options': [
        'Chamber of Secrets',
        'Philosopher\'s Stone',
        'Prisoner of Azkaban',
        'Goblet of Fire',
      ],
      'correctAnswerIndex': 1,
      'category': 'Literature',
      'difficulty': 'Easy',
      'explanation':
          'Harry Potter and the Philosopher\'s Stone (or Sorcerer\'s Stone in the US) is the first book.',
      'points': 10,
    },
    {
      'id': 'lit_005',
      'question': 'Who wrote "To Kill a Mockingbird"?',
      'options': [
        'Harper Lee',
        'Toni Morrison',
        'Maya Angelou',
        'Zora Neale Hurston',
      ],
      'correctAnswerIndex': 0,
      'category': 'Literature',
      'difficulty': 'Medium',
      'explanation':
          'Harper Lee wrote "To Kill a Mockingbird", published in 1960.',
      'points': 20,
    },
  ];

  List<TriviaQuestion> getAllQuestions() {
    return _triviaDatabase
        .map((data) => TriviaQuestion.fromJson(data))
        .toList();
  }

  List<TriviaQuestion> getQuestionsByCategory(String category) {
    return _triviaDatabase
        .where((data) => data['category'] == category)
        .map((data) => TriviaQuestion.fromJson(data))
        .toList();
  }

  List<TriviaQuestion> getQuestionsByDifficulty(String difficulty) {
    return _triviaDatabase
        .where((data) => data['difficulty'] == difficulty)
        .map((data) => TriviaQuestion.fromJson(data))
        .toList();
  }

  List<TriviaQuestion> getRandomQuestions(
    int count, {
    String? category,
    String? difficulty,
  }) {
    List<Map<String, dynamic>> filteredQuestions = _triviaDatabase;

    if (category != null) {
      filteredQuestions =
          filteredQuestions
              .where((data) => data['category'] == category)
              .toList();
    }

    if (difficulty != null) {
      filteredQuestions =
          filteredQuestions
              .where((data) => data['difficulty'] == difficulty)
              .toList();
    }

    // Shuffle the list (web-safe implementation)
    filteredQuestions = _shuffleList(filteredQuestions);

    // Take the requested count or all available questions if less
    int takeCount =
        count > filteredQuestions.length ? filteredQuestions.length : count;

    return filteredQuestions
        .take(takeCount)
        .map((data) => TriviaQuestion.fromJson(data))
        .toList();
  }

  List<String> getAvailableCategories() {
    return _triviaDatabase
        .map((data) => data['category'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> getAvailableDifficulties() {
    return _triviaDatabase
        .map((data) => data['difficulty'] as String)
        .toSet()
        .toList();
  }

  GameSession createGameSession({
    String? category,
    String? difficulty,
    int questionCount = 10,
  }) {
    final questions = getRandomQuestions(
      questionCount,
      category: category,
      difficulty: difficulty,
    );

    return GameSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      questions: questions,
    );
  }

  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (final category in getAvailableCategories()) {
      stats[category] = getQuestionsByCategory(category).length;
    }
    return stats;
  }

  TriviaQuestion? getQuestionById(String id) {
    try {
      final data = _triviaDatabase.firstWhere((q) => q['id'] == id);
      return TriviaQuestion.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
