class Constants {
  // API Configuration
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY'; // Default key, will be overridden by .env
  static const String openaiApiUrl = 'https://api.openai.com/v1/chat/completions';

  // App Strings
  static const String appName = 'Career Improvement App';
  static const String careerAdvisorPrompt = 'You are a career advisor.';

  // Error Messages
  static const String apiKeyMissingError = 'API key is missing or invalid.';
  static const String quotaExceededError = 'Quota exceeded. Please check your plan and billing details.';
  static const String apiRequestFailedError = 'Failed to get suggestions. Please try again later.';
}
