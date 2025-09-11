# MoMo Fraud Detection App

A Flutter application designed to help users in Ghana detect fraudulent SMS messages targeting mobile money (MoMo) transactions.

## Features

### 🛡️ Fraud Detection
- **Real-time SMS Monitoring**: Automatically analyzes incoming mobile money SMS messages
- **Manual Scanning**: Scan your SMS inbox for fraudulent messages  
- **API Integration**: Uses advanced fraud detection API with local fallback
- **Background Processing**: Continuous monitoring using WorkManager
- **Instant Alerts**: Immediate warnings for detected fraud attempts

### 📊 Analytics & Insights
- Fraud detection statistics and trends
- Risk level categorization (Low, Medium, High, Critical)
- Detailed analysis with confidence scores
- Historical scan results and reporting

### 🔒 Security & Privacy
- Local data storage with encryption
- Secure API communication
- Permission-based SMS access
- No external storage of sensitive SMS content

## Key Components

- **SMS Scanner**: Core fraud detection interface
- **Background Service**: Continuous SMS monitoring
- **API Integration**: `/api/fraud-detection/analyze-text` endpoint
- **Local Analysis**: Heuristic-based fraud detection fallback
- **User Dashboard**: Statistics and fraud insights

## Documentation

- [Fraud Detection Documentation](./FRAUD_DETECTION.md) - Detailed technical documentation
- [API Integration Guide](./FRAUD_DETECTION.md#api-integration) - API usage and response format

## Getting Started

### Prerequisites
- Flutter SDK 3.24.4 or higher
- Android SDK for mobile testing
- SMS permissions on target device

### Installation
1. Clone the repository
2. Install dependencies: `flutter pub get`
3. Configure API endpoint in `base_network_service.dart`
4. Run the app: `flutter run`

### Permissions Required
- `READ_SMS`: To read SMS messages for analysis
- `RECEIVE_SMS`: To monitor incoming SMS messages  
- `READ_PHONE_STATE`: For device identification
- `WAKE_LOCK`: For background processing
- `FOREGROUND_SERVICE`: For continuous monitoring

## Usage

1. **Setup**: Grant SMS permissions and enable background monitoring
2. **Manual Scan**: Tap "Scan Now" to analyze your SMS inbox
3. **Review Results**: Check fraud detection results with risk levels
4. **Background Protection**: Automatic monitoring provides real-time alerts

## Development

This Flutter app uses GetX for state management and includes:
- Modular architecture with clear separation of concerns
- Comprehensive error handling and fallback mechanisms
- Local storage for offline functionality
- Background services for continuous protection

## Testing

The app includes demo mode with sample data for testing fraud detection logic without requiring actual SMS messages.

---

For detailed technical documentation, see [FRAUD_DETECTION.md](./FRAUD_DETECTION.md)
