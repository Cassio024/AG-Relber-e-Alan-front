# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please **do not** create a public GitHub issue. Instead, please report it privately to the maintainers.

### How to Report

1. Email the security vulnerability to the project maintainers
2. Include as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Any suggested fixes

We appreciate responsible disclosure and will acknowledge receipt of your report within 48 hours.

## Security Best Practices

### Environment Variables

- **Never** commit `.env` files to version control
- Use `.env.example` to document required environment variables
- Store sensitive credentials in environment variables or secure secret management systems
- For local development, create a `.env.local` file

### Sensitive Files

The following files should never be committed:

- `.env` and `.env.local`
- `firebase.json` (use `.firebaserc` for public config only)
- `google-services.json`
- `GoogleService-Info.plist`
- `android/local.properties`

These files are listed in `.gitignore`.

### API Keys and Credentials

- Store API keys in environment variables or Firebase Secrets
- Rotate API keys regularly
- Never hardcode credentials in source code
- Use Firebase Authentication for user authentication

### Dependencies

- Keep Flutter and all packages up to date
- Regularly review `pubspec.lock` for known vulnerabilities
- Use `flutter pub outdated` to check for updates
- Monitor security advisories for dependencies

### Firebase Configuration

- Ensure Firebase Security Rules are properly configured
- Use appropriate authentication methods
- Validate all data on the backend
- Never expose sensitive configuration in client code

## Version Support

Security updates are provided for the latest version of this project. Users are encouraged to keep their installations up to date.

## Acknowledgments

We thank the security researchers who responsibly disclose vulnerabilities.
