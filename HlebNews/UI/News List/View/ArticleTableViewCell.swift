import UIKit

class ArticleTableViewCell: UITableViewCell {

    struct Model {
        let title: String?
        let publisher: String?
        let publishedAt: String?
        var viewsCount: String?
        let description: String?
    }

    @IBOutlet private weak var articleNameLabel: UILabel!
    @IBOutlet private weak var backgroundCellView: UIView!
    @IBOutlet private weak var publisherNameLabel: UILabel!
    @IBOutlet private weak var publishAtLabel: UILabel!
    @IBOutlet private weak var viewsCountLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupBackground()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        articleNameLabel.text = nil
    }

    private func setupBackground() {
        backgroundCellView.layer.cornerRadius = 10
        backgroundCellView.layer.shadowRadius = 10
        backgroundCellView.layer.shadowOpacity = 0.2
    }

    func setup(from model: Model) {
        articleNameLabel.text = model.title
        publisherNameLabel.text = model.publisher
        publishAtLabel.text = model.publishedAt
        viewsCountLabel.text = model.viewsCount
        descriptionLabel.text = model.description
    }
}
