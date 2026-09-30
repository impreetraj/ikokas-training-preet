# ai_flutter

This is a Flutter chatbot application that integrates with Google's Gemini API. The app uses the Riverpod package for state management.

The core functionality involves sending user prompts to the Gemini AI and displaying the responses. The app manages the chat state (the list of messages and loading status) using a Riverpod StateNotifier. 

When a user submits a prompt, the application makes an HTTP POST request to the Google Gemini API using the Dio package. The API key required for this request is stored securely in a local `.env` file and loaded at runtime using the flutter_dotenv package. 

Once the Gemini API returns a response in JSON format, the application parses the data to extract the AI's generated text. The chat state is then updated with this new message. To properly display the AI's response, which often contains markdown formatting (like bold text, lists, or code blocks), the application uses the flutter_markdown_plus package to render the text. The intl package is used for formatting timestamps on the messages.

Technologies used: Flutter, flutter_riverpod, Dio, flutter_dotenv, flutter_markdown_plus, intl.

## Working Flow
1. Open the app -> The Riverpod state initializes an empty chat history.
2. Submit a prompt -> The user enters text. The Riverpod controller adds the user's message to the state and sets a loading flag.
3. API Request -> The app reads the API key using flutter_dotenv and sends the user's text to the Gemini API via a Dio POST request.
4. Receive Response -> The app receives the JSON response from Gemini, extracts the text, and updates the Riverpod state with the new AI message.
5. Render Text -> The UI rebuilds, and the flutter_markdown_plus widget renders the AI's message, applying appropriate formatting to any markdown syntax.
