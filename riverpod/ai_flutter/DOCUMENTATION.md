# ai_flutter

This is a Flutter AI chatbot application that integrates with Google's Gemini API. It uses Riverpod for state management and renders AI responses as formatted markdown.

The app opens directly to the AI chat screen. The user types a message at the bottom, and the ChatController (a Riverpod StateNotifier) takes over. It adds the user's message to the chat state, shows a loading indicator, and sends the prompt to the GeminiService. This service uses Dio to make a POST request to Google's Gemini API endpoint, passing the user's text in the required format. The API key is loaded securely from a .env file using flutter_dotenv, which is bundled as an asset in the app.

When the Gemini API responds, the service parses the response JSON to extract the AI's text from the candidates array. The ChatController then updates the chat state with the new AI message, and the UI rebuilds. Each message is represented by a MessageModel that tracks the text content, whether it's from the user or the AI, and a timestamp formatted with intl.

The chat messages are displayed in a scrollable list of MessageBubble widgets. The AI's responses are rendered using flutter_markdown_plus, which means code blocks, bold text, lists, and other markdown formatting from the AI come through beautifully styled. User messages and AI messages are visually differentiated with different bubble styles.

The chat history lives entirely in memory through the ChatState model, so it resets when the app is restarted.

Technologies used: Flutter, flutter_riverpod, Dio, flutter_dotenv, flutter_markdown_plus, intl.

## Working Flow
1. Open the app -> The AI Chat Screen appears instantly.
2. Type a message in the text field -> The UI updates to show your message bubble on the right side.
3. Click Send -> The Riverpod ChatController shows a loading indicator and makes a POST request to the Google Gemini API using Dio and your hidden .env API key.
4. Wait for response -> The API returns a JSON response containing the AI's answer.
5. Message received -> The loading indicator disappears, and the AI's response is appended to the chat on the left side.
6. Read the AI message -> The flutter_markdown_plus package renders the AI's text, formatting any code blocks, bullet points, or bold text beautifully.
