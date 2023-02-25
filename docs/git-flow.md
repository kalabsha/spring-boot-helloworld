# Git Flow

In this short article, we will explain the concept of Git Flow briefly.

Git Flow is one of the most wide known **workfow**s. The others are **GitHub Flow**, **GitLab Flow**, **One Flow** and so on. 

Git Flow is based on two long-lived/permant branches.

- `main/master`, we use `main` in this article. It is the de facto production, all codes will be merged into this branch sooner or later.
- `develop`, pre-production. When we complete the features coding, the `feature` branch will be merged into `develop`.

There are also other type of branches besides these two long-lived branches.

- Feature branches, for developing new features in the next release cycle. Feature branches **always** use `develop` as their parent branch and when a feature is complete, it gets merged back into `develop`. Features should never interact directly with `main`.

    ```bash
    # Starting 
    git checkout develop
    git checkout -b feature

    # Finishing
    git checkout develop
    git merge feature
    ```

- Hotfix branches, maintenance or `hotfix` branches are used to quickly patch production releases. This is the only branch that should fork directly off of `main`. As soon as the fix is complete, it should be merged into both `main` and `develop`.

    ```bash
    # Starting 
    git checkout main
    git checkout -b hotfix

    # Finishing
    git checkout main
    git merge hotfix
    git checkout develop
    git merge hotfix
    git branch -D hotfix
    ```

- Release branches, are based on a **ready to release** `develop` branch, which means `develop` has acquired enough features for a release  or a predetermined release date is approaching. So, only bug fixes, documentation generation, and other release-oriented tasks should go in this branch. Once it's ready, the release branch gets merged into `main` and tagged with a version number. It should also be merged back into `develop`, which may have progressed since the release was initiated.

    ```bash
    # Starting 
    git checkout develop
    git checkout -b release/v0.1.0

    # Finishing
    git checkout main
    git merge release/v0.1.0
    git checkout develop
    git merge release/v0.1.0    
    ```

## Advantages

- The two long-lived branches are clean during the release cycle.
- The branches naming method is understood at ease.
- Widely supported by most git tools
- It is well designed for maintaining multiple production versions in the project.

## Shortcomings

- The Git history grows, which lacks of readability.
- The long-lived feature branches require more collaboration to merge and have a higher risk of deviating from the trunk branch which can also introduce conflicting updates.


## Summary

Git Flow is one of many styles of Git workflows.

Some key takeaways to know about Git Flow are:

-  The workflow is great for a release-based software workflow.
-  Git Flow offers a dedicated channel for hotfixes to production.

The overall flow of Git Flow is:

- A develop branch is created from main
- A release branch is created from develop
- Feature branches are created from develop
- When a feature is complete it is merged into the develop branch
- When the release branch is done it is merged into develop and main
- If an issue in main is detected a hotfix branch is created from main
- Once the hotfix is complete it is merged to both develop and main

---

## References

- [Atlassian Tutorials: Gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
- [Origin Post of Git Flow](https://nvie.com/posts/a-successful-git-branching-model/)
- [Gitflow the Tool](https://github.com/nvie/gitflow)
