import UIKit

// MARK: - Data model
// вопрос
private struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

// MARK: - ViewModels
// для состояния "Вопрос задан"
private struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

// для состояния "Результат квиза"
private struct QuizResultsViewModel {
    let title: String
    let text: String
    let buttonText: String
}

final class MovieQuizViewController: UIViewController {
    
    private let mainStackView = UIStackView()
    
    private let questionTitleStackView = UIStackView()
    private let questionTitleLabel = UILabel()
    private let questionIndexLabel = UILabel()
    
    private let previewImageViewStackView = UIStackView()
    private let leftPaddingView = UIView()
    private let rightPaddingView = UIView()
    private let previewImageView = UIImageView()
    
    private let questionLabelView = UIView()
    private let questionLabel = UILabel()
    
    private let buttonsStackView = UIStackView()
    private let yesButton = UIButton()
    private let noButton = UIButton()
    
    // MARK: - Properties
    private var currentQuestionIndex = 0 {
        didSet {
            showCurrentQuestion()
        }
    }
    private var questions: [QuizQuestion] = []
    private var correctAnswers = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        applyStyle()
        applyLayout()
        
        startQuiz()
    }
}

// MARK: - State's methods
extension MovieQuizViewController {
    private func startQuiz() {
        questions.shuffle()
        currentQuestionIndex = 0
        correctAnswers = 0
    }
    
    private func showCurrentQuestion() {
        let currentQuestion = questions[currentQuestionIndex]
        let quiz = convert(model: currentQuestion)
        show(quiz: quiz)
    }
    
    private func show(quiz step: QuizStepViewModel) {
        questionIndexLabel.text = step.questionNumber
        previewImageView.image = step.image
        questionLabel.text = step.question
        
        setPreviewImageViewBorder()
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.startQuiz()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers) из \(questions.count)"
            let result = QuizResultsViewModel(
                title: "Раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            show(quiz: result)
        } else {
            currentQuestionIndex += 1
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        let color = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        setPreviewImageViewBorder(width: Theme.imageAnswerBorderWidht, color: color)
        
        [noButton, yesButton].forEach { $0.isEnabled.toggle() }
        // у нас здесь один ссылочный объект, значит и цикла удержания не может быть
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [unowned self] in
            showNextQuestionOrResults()
            [noButton, yesButton].forEach { $0.isEnabled.toggle() }
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)")
    }
}

// MARK: - Private methods setup and UI
extension MovieQuizViewController {
    private func setup() {
        questions = loadMockData()
        
        yesButton.addTarget(self, action: #selector(yesButtonTapped), for: .primaryActionTriggered)
        noButton.addTarget(self, action: #selector(noButtonTapped), for: .primaryActionTriggered)
    }

    private func applyStyle() {
        view.backgroundColor = .ypBlack
        
        applyStyleLabel(for: questionTitleLabel, text: "Вопрос:")
        applyStyleLabel(for: questionIndexLabel, text: "1/10", textAlignment: .right)
        
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.backgroundColor = .ypWhite
        previewImageView.layer.cornerRadius = Theme.imageCornerRadius
        previewImageView.layer.masksToBounds = true
        
        questionLabelView.backgroundColor = .ypBlack
        
        applyStyleLabel(
            for: questionLabel,
               text: "Рейтинг этого фильма меньше чем 5?",
               font: Theme.boldLargeFont,
               textAlignment: .center,
               numberOfLines: 0)
        
        applyStyleAnswerButton(for: yesButton, title: "Да")
        applyStyleAnswerButton(for: noButton, title: "Нет")
    }

    private func applyLayout() {
        arrangeStackView(
            for: questionTitleStackView,
               subviews: [questionTitleLabel, questionIndexLabel])
        
        questionIndexLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        arrangeStackView(
            for: previewImageViewStackView,
               subviews: [leftPaddingView, previewImageView, rightPaddingView])
        
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabelView.addSubview(questionLabel)
        
        questionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        arrangeStackView(
            for: buttonsStackView,
               subviews: [noButton, yesButton],
               spacing: Theme.spacing,
               distribution: .fillEqually)
        
        arrangeStackView(
            for: mainStackView,
               subviews: [questionTitleStackView, previewImageViewStackView, questionLabelView, buttonsStackView],
               spacing: Theme.spacing,
               axis: .vertical)
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.leftOffset),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.leftOffset),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.topOffset),
            mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            previewImageView.heightAnchor.constraint(equalTo: previewImageView.widthAnchor, multiplier: Theme.imageHeightAspect),
            leftPaddingView.widthAnchor.constraint(equalTo: rightPaddingView.widthAnchor),
            
            questionLabel.leadingAnchor.constraint(equalTo: questionLabelView.leadingAnchor, constant: Theme.leftQuestionPadding),
            questionLabel.trailingAnchor.constraint(equalTo: questionLabelView.trailingAnchor, constant: -Theme.leftQuestionPadding),
            questionLabel.topAnchor.constraint(equalTo: questionLabelView.topAnchor, constant: Theme.topQuestionPadding),
            questionLabel.bottomAnchor.constraint(equalTo: questionLabelView.bottomAnchor, constant: -Theme.topQuestionPadding),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: Theme.buttonHeight),
        ])
    }
    
    // MARK: - Supporting methods
    private func applyStyleLabel(
        for label: UILabel,
        text: String,
        font: UIFont? = Theme.mediumLargeFont,
        textColor: UIColor = .ypWhite,
        textAlignment: NSTextAlignment = .left,
        numberOfLines: Int = 1
    ) {
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
    }
    
    private func applyStyleAnswerButton(for button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Theme.mediumLargeFont
        button.setTitleColor(.ypBlack, for: .normal)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = Theme.buttonCornerRadius
        button.layer.masksToBounds = true // стоит ли выставлять? Критично только для image
    }
    
    private func setPreviewImageViewBorder(width: CGFloat = 0, color: CGColor = UIColor.ypWhite.cgColor) {
        previewImageView.layer.borderWidth = width
        previewImageView.layer.borderColor = color
    }
    
    private func arrangeStackView(
        for stackView: UIStackView,
        subviews: [UIView],
        spacing: CGFloat = 0,
        axis: NSLayoutConstraint.Axis = .horizontal,
        distribution: UIStackView.Distribution = .fill,
        aligment: UIStackView.Alignment = .fill
    ) {
        stackView.axis = axis
        stackView.spacing = spacing
        stackView.distribution = distribution
        stackView.alignment = aligment
        
        subviews.forEach { item in
            item.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview(item)
        }
    }
}

// MARK: - Actions
extension MovieQuizViewController {
    @objc func yesButtonTapped() {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: true == currentQuestion.correctAnswer)
    }
    
    @objc func noButtonTapped() {
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: false == currentQuestion.correctAnswer)
    }
}

// MARK: - Theme
enum Theme {
    static let boldLargeFont = UIFont(name: "YSDisplay-Bold", size: 23)
    static let boldSmallFont = UIFont(name: "YSDisplay-Bold", size: 18)
    static let mediumLargeFont = UIFont(name: "YSDisplay-Medium", size: 20)
    static let mediumSmallFont = UIFont(name: "YSDisplay-Medium", size: 16)
    
    static let buttonCornerRadius: CGFloat = 15
    static let buttonHeight: CGFloat = 60
    
    static let imageCornerRadius: CGFloat = 20
    static let imageAnswerBorderWidht: CGFloat = 8
    static let imageHeightAspect: CGFloat = 3/2
    
    static let spacing: CGFloat = 20
    static let leftOffset: CGFloat = 20
    static let topOffset: CGFloat = 10
    static let leftQuestionPadding: CGFloat = 42
    static let topQuestionPadding: CGFloat = 13
}

// MARK: - Mock data
extension MovieQuizViewController {
    private func loadMockData() -> [QuizQuestion]{
        [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    }
}
