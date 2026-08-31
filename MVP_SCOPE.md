# MVP Scope

## What is in the MVP

### Collector Flow (complete)
- Demo login with language selection
- Home screen with primary "Sell Scrap" action
- Photo capture or gallery selection
- Material classification (demo classifier)
- Weight entry with quick-select buttons
- Price estimate with fair range, trend, data points
- Recycler matching with scored results
- Smart aggregation opportunities
- Offer viewing and acceptance
- Handover with photo and weight confirmation
- Payment recording (Cash, UPI, Bank Transfer)
- Material passport with traceability timeline
- Earnings summary
- Safety guide with voice

### Recycler Features
- View incoming lots
- Make offers on lots
- Confirm handover with final weight
- Record payments
- Publish material demands
- Update lot status through processing/recycling

### Admin Features
- System metrics dashboard
- Transaction list with filters
- Flagged transaction view
- Recycler management view

### Platform Intelligence
- Price estimation from observation data
- Price trends (7d, 30d, 90d)
- Recycler matching scores
- Transaction anomaly detection
- Smart aggregation with group premium calculation

### Offline Support
- Local SQLite for lot creation
- Cached materials, prices, recyclers
- Sync queue with retry
- Visual sync status indicators

### Language Support
- English
- Hindi
- Marathi
- Voice output for prices, materials, safety

### Demo Data
- 8 material categories with Hindi/Marathi names
- 3 demo collectors
- 5 demo recyclers with varied auth statuses
- 30+ price observations per material (90 days)
- 10+ demo transactions with traceability
- 5+ active recycler demands
- 2+ aggregation groups

## What is NOT in the MVP

- Real ML model for material classification
- Real payment gateway integration
- OTP or OAuth authentication
- Push notifications
- Real-time chat
- Blockchain anything
- Complex KYC or compliance workflows
- Government API integration
- Nationwide recycler onboarding
- Custom-trained AI models
- IoT integration
- Social features
- Gamification or tokens

## Known Limitations

1. Demo classifier returns deterministic results, not real image analysis
2. Price data is seeded, not live market data
3. Recycler authorization references are demo placeholders
4. No real payment processing
5. GPS simulation in emulator
6. SQLite limits concurrent access (fine for demo)
7. No file upload in sync (photos stored as references)
8. Voice quality depends on device TTS engine
