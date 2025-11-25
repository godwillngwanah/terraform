# Cleanup large `.terraform` artifacts and purge history

Run these commands from PowerShell in the `terraform` folder:

1) Quick fix (if the large file is only in the latest commits)

```powershell
# Remove the directory from the index but keep files locally
git rm -r --cached .terraform

# Ensure .gitignore is staged
git add .gitignore

# Commit and push
git commit -m "Remove .terraform from repo and ignore it"
git push origin main
```

If `git push` still fails with a large-file error, the file is in earlier commits and you must rewrite history.

2) Full-history purge using `git filter-repo` (recommended)

Prerequisites: Python and `pip` available locally.

```powershell
# Install filter-repo if needed
pip install git-filter-repo

# Create a backup of the folder before rewriting history
cd ..
Copy-Item -Recurse -Force .\terraform .\terraform-backup
cd .\terraform

# Remove the specific large file from all commits (replace path if different)
git filter-repo --invert-paths --paths .terraform/providers/registry.terraform.io/hashicorp/aws/6.21.0/windows_amd64/terraform-provider-aws_v6.21.0_x5.exe

# OR remove the entire .terraform folder from history
git filter-repo --invert-paths --paths .terraform

# Force-push cleaned refs to remote (will rewrite remote history)
git push origin --force --all
git push origin --force --tags
```

Notes and warnings:
- Rewriting history is destructive: coordinate with collaborators. They should re-clone or run a hard reset after you push.
- Keep the backup created above until you're sure the cleaned repo is correct.

3) Optional: Use Git LFS going forward

```powershell
git lfs install
git lfs track ".terraform/**/terraform-provider-*.exe"
git add .gitattributes
git commit -m "Track provider binaries with Git LFS"
```

Git LFS doesn't retroactively move already-committed files into LFS; it only affects future commits.

Post-clean checklist
- Verify `git log --all -- .terraform` contains no references to the large file.
- Ask collaborators to re-clone: `git clone <repo-url>` or run `git fetch --all` and `git reset --hard origin/main`.
- Remove the `terraform-backup` when you are satisfied.
