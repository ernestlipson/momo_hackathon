# Fraud Detection Feature Documentation

## Overview
This MoMo (Mobile Money) fraud detection application helps users identify fraudulent SMS messages targeting mobile money transactions in Ghana. The app uses both API-based analysis and local heuristics to detect various types of fraud.

## Key Features

### 1. Real-time SMS Monitoring
- **Background Service**: Continuously monitors incoming SMS messages using WorkManager
- **Real-time Analysis**: Automatically analyzes mobile money related SMS messages
- **Instant Alerts**: Shows immediate warnings for detected fraud attempts

### 2. Manual SMS Scanning  
- **Inbox Scan**: Users can manually scan their SMS inbox for fraudulent messages
- **Batch Analysis**: Processes multiple messages at once
- **Historical Results**: Stores and displays analysis history

### 3. API Integration
- **Primary Analysis**: Uses `/api/fraud-detection/analyze-text` endpoint for advanced fraud detection
- **Fallback System**: Local analysis when API is unavailable
- **Response Mapping**: Maps API response to app's fraud result model

## API Integration

### Endpoint
```
POST /api/fraud-detection/analyze-text
```

### Request Format
```json
{
  "text": "SMS message body",
  "sender": "Sender name/number", 
  "timestamp": "2024-01-15T14:35:00.000Z",
  "messageId": "unique_message_id",
  "source": "SMS_SCAN"
}
```

### Expected Response Format  
```json
{
  "message": "SMS fraud detection analysis completed successfully",
  "data": {
    "transactionId": "SMS_1704461700000",
    "status": "FRAUD", // FRAUD, SUSPICIOUS, SAFE
    "confidence": 95, // Percentage 0-100
    "riskFactors": [
      "Requests personal information",
      "Urgent language"
    ],
    "analysisDetails": "FRAUD - This SMS uses urgent language and asks for PIN...",
    "source": "USER_SCAN",
    "timestamp": "2024-01-15T14:35:00.000Z"
  }
}
```

## Fraud Detection Logic

### Local Heuristics
The app includes local fraud detection logic that checks for:

1. **Phishing Indicators**
   - Requests for verification or account confirmation
   - Suspicious links (bit.ly, tinyurl, IP addresses)
   - Security alerts and urgent action requests

2. **Social Engineering Tactics**  
   - Lottery/prize notifications
   - Inheritance claims
   - Free money offers
   - Congratulatory messages

3. **Sender Verification**
   - Impersonation of legitimate services (MTN, Vodafone, etc.)
   - Suspicious sender patterns
   - Unknown/suspicious phone numbers

4. **Content Analysis**
   - Urgent/threatening language
   - Requests for personal information (PIN, passwords)
   - Unusual transaction amounts
   - Grammar and spelling inconsistencies

## Background Monitoring

### WorkManager Integration
- **Periodic Tasks**: Checks for new SMS messages every 15 minutes
- **Real-time Listener**: Active SMS receiver when app is running
- **Battery Optimization**: Efficient background processing

### Permissions Required
```xml
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

## User Interface Features

### Permission Management
- SMS permission request flow
- Permission status indicator
- Clear permission instructions

### Background Monitoring Control
- Toggle switch for background monitoring
- Real-time status display  
- Monitoring state persistence

### Results Display
- Color-coded risk levels (Low, Medium, High, Critical)
- Detailed fraud analysis with confidence scores
- Risk factors and red flags highlighting
- Historical scan results

### Statistics Dashboard
- Total messages scanned
- Fraud detection count
- Success rate metrics
- Last scan timestamp

## Testing & Validation

### Demo Mode
- Sample fraudulent and legitimate SMS messages
- Simulated API responses for testing
- Local analysis demonstration

### Error Handling
- Network connectivity issues
- API rate limiting
- Permission denial scenarios
- Background service failures

## Security Considerations

1. **Data Privacy**: SMS content is only analyzed, never permanently stored externally
2. **Local Storage**: Results stored locally with encryption
3. **API Security**: Secure HTTPS communication with authentication
4. **Permission Model**: Only requests necessary permissions

## Usage Instructions

1. **Initial Setup**
   - Grant SMS reading permissions
   - Enable background monitoring
   - Configure API connection (if available)

2. **Manual Scanning**
   - Tap "Scan Now" button
   - Review results with risk levels
   - Check detailed analysis for flagged messages

3. **Background Monitoring**  
   - Enable automatic monitoring toggle
   - Receive instant fraud alerts
   - Check pending alerts when opening app

4. **Managing Results**
   - View scan history
   - Clear old data when needed
   - Export/share suspicious message details

## Development Notes

### Key Files
- `fraud_detection_service.dart`: Core API integration and local analysis
- `background_sms_service.dart`: WorkManager background processing
- `sms_scanner_controller.dart`: Main controller with UI logic
- `sms_scanner_view.dart`: User interface components

### Dependencies
- `sms_advanced`: SMS reading capabilities
- `workmanager`: Background task processing  
- `permission_handler`: Permission management
- `get_storage`: Local data persistence
- `dio`: HTTP client for API calls

### Future Enhancements
- Machine learning model integration
- User feedback loop for improving detection
- Community-based fraud reporting
- Integration with telecom providers
- Multi-language support for local languages