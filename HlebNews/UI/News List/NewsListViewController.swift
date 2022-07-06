import UIKit

final class NewsListViewController: BaseViewController {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var newsTableView: UITableView!
    private let refreshControl = UIRefreshControl()

    var viewModel: NewsListViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        viewModel.viewDidLoad()

           refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
           newsTableView.addSubview(refreshControl)
    }

    private func bindViewModel() {
        viewModel.didLoadFirstNews = { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.newsTableView.isHidden = false
                self?.newsTableView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }

        viewModel.didReceiveError = { [weak self] message in
            DispatchQueue.main.async {
                self?.showAlert(message: message)
            }
        }

        viewModel.didUpdateAt = { [weak self] index in
            DispatchQueue.main.async {
                self?.newsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }

    @objc private func refresh(_ sender: AnyObject) {
        viewModel.update()
    }
}

extension NewsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell") as? ArticleTableViewCell else {
            return UITableViewCell()
        }
        cell.setup(from: viewModel.dataSource[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didTapArticle(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (indexPath.row + 2) == viewModel.dataSource.count {
            viewModel.loadMore()
        }
    }
}
