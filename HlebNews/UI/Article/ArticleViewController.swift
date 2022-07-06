import UIKit

final class ArticleViewController: BaseViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var cintentTextView: UITextView!

    var viewModel: ArticleViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setupContent()

        viewModel.viewDidLoad()
    }

    private func bindViewModel() {
        viewModel.didLoadImage = { [weak self] data in
            DispatchQueue.main.async {
                self?.imageView.image = UIImage(data: data)
            }
        }
    }

    private func setupContent() {
        titleLabel.text = viewModel.article.title
        descriptionLabel.text = viewModel.article.description
        cintentTextView.text = viewModel.article.content
    }

    @IBAction private func didTapOpenFullNews(_ sender: Any) {
        viewModel.didTapOpenNews()
    }

}
