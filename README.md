# ALog

<img src="Images/Promo.png" style="max-height: 400px" />

## Installation

[![Download ALog on the App Store](https://linkmaker.itunes.apple.com/images/badges/en-us/badge_appstore-lrg.svg)](https://apps.apple.com/us/app/alog/id6451082482)

## Building the project

Follow these steps to build the project:

#### 1. Clone the repo

```shell
git clone https://github.com/duxins/alog
```

#### 2. Install xcodegen

```shell
brew install xcodegen
```

#### 3. Install Ruby gems

```shell
bundle install
```

#### 4. Copy .env.example to .env

To setup up the environment variables, copy the `.env.example` file and rename it as `.env`.

```shell
cp .env.example .env
```

Update the keys as needed within the .env file.

#### 5. Generate the Arkana package

```shell
bundle exec bin/arkana
```

#### 6. Generate the project

Finally, generate the project by running:

```shell
xcodegen
```

Once you've followed these steps, you should have a fully built project ready for development. If you encounter any issues, please open an issue in the repository.

## Deploying server-side code to Cloudflare

### Steps: 

#### 1. Create a new Cloudflare worker

* Once logged in, navigate to the "**Workers & Pages**" section.
* Click on "**Create Application**" → "**Create Worker**".
* Rename the Worker as per your requirements.
* Click on "**Deploy**".

#### 2. Configure your worker

* After deploying, you'll see a "**Quick Edit**" button. Click on it.
* Paste the contents of [Server/src/worker.js](Server/src/worker.js) into the Cloudflare Worker editor.
* Click on "**Save and deploy**"

#### 3. Set Environment variables:

* On the Worker's **Settings** tab, navigate to the **Variables** section.
* Set the following variables:

| Variable         |            | Description          |
|------------------|------------|----------------------|
| **`OPENAI_KEY`** | *Required* | Your OpenAI API key. |
| **`HMAC_KEY`**   | *Optional* | This should be consistent with the key used on the client side. If this variable is not set, HMAC validation will not be performed. |
| **`AI_MODEL`**   | *Optional* | Represents the default model. If not set, the model specified by the client will be used.                                           |

#### 4. Update API base URL

* Open `Constants.swift` file.
* Update the `api_base_url` constant to point to the URL of your deployed Cloudflare Worker.

```swift
struct Constants {
    static let api_base_url = URL(string: "https://your-worker-name.workers.dev/")!
}
```

## License

Distributed under the GNU General Public License v2.0. See [LICENSE](./LICENSE) for more information.

**Important Note:** This open-source license does not prevent anyone from renaming and repackaging this app for distribution. However, doing so is in direct violation of App Store Review Guidelines, specifically Guideline 4.1 (Copycats) and Guideline 4.3 (Spam). Any attempt to simply rename and repackage this app for submission to the App Store is explicitly prohibited.

## Credits

Thanks to [@onenewbite](https://twitter.com/onenewbite) for his inspiring video "[为什么你应该开始用ChatGPT写日记|做笔记](https://www.youtube.com/watch?v=ZRv0Z-M7NqM)", which has greatly influenced this project.
