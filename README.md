# Initialization `news_app` Application Configuration

## Run Configuration

### FVM

- Ensure **Flutter Version Management (FVM)** is installed.
- Run the following command to select the correct Flutter version for the project:

  ```bash
  fvm use 3.29.2
  ```

### Gen-l10n

- Generate localized strings for the application by running:

  ```bash
  fvm flutter gen-l10n
  ```

### Create Generated Files

- Run the following command to generate files like serializers, adapters, or other auto-generated code:

  ```bash
  fvm flutter packages pub run build_runner build
  ```

### Create `.env`

- Open `env.md` for reference on environment variables.
- Set up a `.env` file in the root directory of the project.
- Add environment variables such as API keys, base URLs, or other configuration settings:

  ```env

  ```

### Install Dependencies

- Ensure all necessary dependencies are installed by running:

  ```bash
  fvm flutter pub get
  ```

### Run the Application

- Use the following command to run the application in debug mode:

  ```bash
  fvm flutter run
  ```

### Build the Application

- To generate a release build, use:

  ```bash
  fvm flutter build apk --release
  ```

  or for iOS:

  ```bash
  fvm flutter build ios --release
  ```
