## How to contribute

### Check previous issues
Look at the issue tracker page. Is there an issue related to your contribution? If not consider creating one so others will know someone is aware of the issue and working on it. The issue page and comment thread are a great places to collect your thoughts on the problem and solution.

### Branching

* Branch `master` is always stable and release-ready.
* Branch `develop` is for development and merged into `master` when stable.
* Feature branches should be created for adding new features and merged into `develop` when ready.
* Bug fix branches should be created for fixing bugs and merged into `develop` when ready.
* See also: [*A successful Git branching model*](http://nvie.com/posts/a-successful-git-branching-model).

### Submitting

1. Find an issue to work on, or create a new one. *Avoid duplicates, please check existing issues!*
2. Fork the repo, or make sure you are synced with the latest changes on `develop`.
3. Create a new branch with a sweet name: `git checkout -b issue_<##>_<description>`.
4. Write [unit tests](http://nshipster.com/unit-testing) when applicable.
5. Keep your code nice and clean by adhering to the coding standards & guidelines below.
6. Don't break unit tests or functionality.
7. Update the documentation header comments if needed.
8. Rebase on `develop` branch and resolve any conflicts _before submitting a pull request!_
9. Submit a pull request to the `develop` branch.

### Style guidelines

Clarity and readability should be prioritized, while redundancy should be avoided. Remember that [verboseness does not necessarily yield clarity](http://radex.io/swift/methods/). 

Adhere to the following sets of guidelines. In the event of contradictory rules, the order of the guides below denotes their precedence.

1. GitHub's [Swift Style Guide](https://github.com/github/swift-style-guide)
2. Ray Wenderlich's [Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)