# Offline Sync Architecture

## Design

The mobile app operates offline-first. A collector can create lots, view cached prices, and browse saved recycler data without any internet connection.

## Local Storage

SQLite on the mobile device stores:

| Table | Contents | Sync Direction |
|-------|----------|----------------|
| lots | Created and cached lots | Bidirectional |
| materials | Material categories | Server → Client |
| prices | Price observations | Server → Client |
| recyclers | Recycler data | Server → Client |
| sync_queue | Pending operations | Client → Server |

## Sync Status per Record

Every locally stored record carries a `sync_status`:

- **LOCAL_ONLY**: Created offline, never sent to server
- **PENDING_SYNC**: Queued for upload
- **SYNCED**: Server confirmed receipt, has server ID
- **SYNC_FAILED**: Upload attempt failed, will retry

## Sync Queue

When the user creates a lot offline:

1. Lot saved to local SQLite with `sync_status = LOCAL_ONLY`
2. Entry added to `sync_queue` table with operation type and data
3. UI shows a "Pending Sync" badge on the lot

## Sync Trigger

Sync runs when:

1. App detects connectivity restored (NetInfo listener)
2. User manually triggers sync from settings
3. App opens with connectivity available

## Sync Flow

```
App detects online
       ↓
Read sync_queue (oldest first)
       ↓
Batch items (max 10 per request)
       ↓
POST /api/sync with batch
       ↓
Server processes each item:
  - Creates server record
  - Returns server_id mapping
       ↓
For each success:
  - Update local record with server_id
  - Set sync_status = SYNCED
  - Remove from sync_queue
       ↓
For each failure:
  - Increment retry_count
  - Set sync_status = SYNC_FAILED
  - Keep in sync_queue
       ↓
Fetch fresh server data:
  - Updated prices
  - Updated recyclers
  - Status changes for synced lots
       ↓
Update local cache
```

## Conflict Handling

Conflicts are rare in the MVP because:
- Lots are created by one collector and flow one direction
- Prices and recyclers are read-only from the client perspective
- Offers and transactions happen online

When a conflict occurs (same lot modified on both sides):
- Server version wins for server-owned fields (status, offers)
- Client version wins for client-owned fields (weight, description, photos)
- Both changes are preserved in the traceability log

## Retry Policy

Failed syncs retry with exponential backoff:
- 1st retry: 30 seconds
- 2nd retry: 2 minutes
- 3rd retry: 10 minutes
- 4th retry: 1 hour
- After 5 failures: stop automatic retry, show "Sync Failed" to user

## Cached Data Freshness

| Data | Cache Duration | Refresh Trigger |
|------|---------------|-----------------|
| Materials | 7 days | App start |
| Prices | 1 hour | App start, manual |
| Recyclers | 4 hours | App start, manual |
| Lots | Realtime local | Sync |

## Data Size Limits

Photos are not synced through the sync endpoint. They are uploaded separately when connectivity is available, and lot records reference photo URLs.

For offline-created lots, photos remain on-device until upload completes. The lot can proceed through the flow with local photo references.

## UI Indicators

The app shows sync status throughout:

- **Header bar**: Online/Offline indicator with color
- **Lot cards**: Sync status badge (green check = synced, orange clock = pending, red x = failed)
- **Settings**: Sync status page showing queue depth and last sync time
- **Sync button**: Manual trigger in settings and pull-to-refresh on lot list
