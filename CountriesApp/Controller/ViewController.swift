//
//  ViewController.swift
//  CountriesApp
//
//  Created by Gytis Ptašinskas on 16/11/2023.
//

import UIKit

class ViewController: UITableViewController {
    
    private let cellID = "cell"
    private let countryAllUrl = "https://restcountries.com/v3.1/all"
    private var countries: [Country] = []
    private var filteredCountries: [Country] = []
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()

        NetworkManager.fetchData(url: countryAllUrl) { countries in
            self.countries = countries
            self.filteredCountries = countries // Initialize filteredCountries
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private func setupView() {
        view.backgroundColor = .secondarySystemBackground
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        setupSearchController()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        tableView.addGestureRecognizer(longPress)
    }

    private func setupNavigationBar() {
        self.title = "Countries"
        let titleImage = UIImage(systemName: "mappin.and.ellipse")
        let imageView = UIImageView(image: titleImage)
        self.navigationItem.titleView = imageView
        
        self.navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.label]
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = .label
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Countries"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCountries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        let country = filteredCountries[indexPath.row]
        cell.textLabel?.text = country.name.common
        cell.detailTextLabel?.text = country.name.official
        return cell
    }

    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: point) {
                let country = filteredCountries[indexPath.row]
                showCountryDetailsAlert(country: country)
            }
        }
    }

    func showCountryDetailsAlert(country: Country) {
        let alert = UIAlertController(title: "\n\n\n\n\n", message: nil, preferredStyle: .alert)
        let message = """
        Official Name: \(country.name.official ?? "N/A")
        Capital: \(country.capital?.joined(separator: ", ") ?? "N/A")
        Region: \(country.region ?? "N/A")
        Population: \(country.population?.description ?? "N/A")
        Continent: \(country.continents?.joined(separator: ", ") ?? "N/A")
        """

        if let flagUrlString = country.flags.png, let flagUrl = URL(string: flagUrlString) {
            URLSession.shared.dataTask(with: flagUrl) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data, let image = UIImage(data: data) {
                        let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 250, height: 100))
                        imageView.contentMode = .scaleAspectFit
                        imageView.image = image
                        alert.view.addSubview(imageView)
                    }

                    alert.message = message
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }.resume()
        } else {
            alert.message = message
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - UISearchResultsUpdating
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredCountries = countries.filter { country in
                country.name.common?.lowercased().contains(searchText.lowercased()) ?? false
            }
        } else {
            filteredCountries = countries
        }
        tableView.reloadData()
    }
}

