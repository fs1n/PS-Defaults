# PowerShell Gallery CI Automation

This repository includes automated publishing to PowerShell Gallery using GitHub Actions.

## Setup Instructions

### 1. Obtain PowerShell Gallery API Key

1. Log into [PowerShell Gallery](https://www.powershellgallery.com/)
2. Navigate to your profile → API Keys → Create a new key
3. Set appropriate scope (push new packages and package versions)
4. **Copy the API key** (it will only be shown once!)

### 2. Add API Key to Repository Secrets

1. Go to GitHub repository → Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `PSGALLERY_API_KEY`
4. Value: Paste your PowerShell Gallery API key
5. Click "Add secret"

### 3. How the Automation Works

The CI workflow (`/.github/workflows/publish-psgallery.yml`) automatically:

#### On Release Creation:
- Validates the module manifest and functionality
- Publishes the module to PowerShell Gallery using `Publish-Module`
- Uses the version specified in `PS-Defaults.psd1`

#### On Push to Main Branch:
- Validates module structure and PowerShell Gallery compliance
- Runs tests to ensure module imports correctly
- Performs dry-run validation (no actual publishing)

### 4. Triggering Publication

To publish a new version:

1. Update the `ModuleVersion` in `PS-Defaults.psd1`
2. Update `ReleaseNotes` in the PSData section (optional but recommended)
3. Create a new release on GitHub:
   - Go to Releases → Create a new release
   - Tag version should match the module version (e.g., `v1.0.1`)
   - The workflow will automatically trigger and publish

### 5. Monitoring

- Check the Actions tab to monitor workflow runs
- Review logs for any errors or issues
- Verify successful publication on PowerShell Gallery

### 6. Module Structure Requirements

The workflow validates:
- ✅ Module manifest (`PS-Defaults.psd1`) is valid
- ✅ Required fields: ModuleVersion, Author, Description, PowerShellVersion
- ✅ PSData section with Tags, LicenseUri, ProjectUri
- ✅ Module imports successfully
- ✅ Core functions are available

### 7. Security Notes

- ⚠️ **Never expose your API key** in code or logs
- ✅ API key is stored securely in GitHub repository secrets
- ✅ Workflow only publishes on release events (not every push)
- ✅ Validation runs on every push to main for early error detection

### 8. Troubleshooting

#### "PSGALLERY_API_KEY secret is not set"
- Ensure you've added the secret with the exact name `PSGALLERY_API_KEY`
- Check that the secret value is not empty

#### "Module already exists with version X.X.X"
- Increment the version in `PS-Defaults.psd1`
- PowerShell Gallery doesn't allow overwriting existing versions

#### Module validation failures
- Check the workflow logs for specific validation errors
- Ensure all required manifest fields are populated
- Test module import locally with `Import-Module ./PS-Defaults.psd1`