Commit all current changes to this nvim config and push to GitHub.

Steps:
1. Run `git -C ~/.config/nvim status` to see what changed.
2. Run `git -C ~/.config/nvim diff` to review the changes.
3. Write a concise, imperative commit message that describes the changes (e.g. "Add TypeScript LSP and prettier formatter").
4. Stage all changed files: `git -C ~/.config/nvim add -A`
5. Commit: `git -C ~/.config/nvim commit -m "<message>"`
6. Push: `git -C ~/.config/nvim push origin main`
7. Report the final git status and the commit hash.

If the remote `origin` is not set, initialize it:
```
git -C ~/.config/nvim remote add origin git@github.com:cmorales95/nvim-config.git
git -C ~/.config/nvim push -u origin main
```
