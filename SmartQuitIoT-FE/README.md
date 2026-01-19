# SmartQuitIoT Frontend

## Schedule Management Tasks

### UI Components Needed:

1. Calendar Component

   - Display work days for each coach
   - Highlight different status with distinct colors
   - Allow date range selection

2. Time Slot Grid

   - Show 16 slots per day
   - Display status (EXPIRED, IN_PROGRESS, BOOKED)
   - Color coding for different states
   - Quick status update functionality

3. Coach Selection

   - Dropdown/List of available coaches
   - Filter schedule by coach

4. Schedule Management Features
   - Bulk schedule creation
   - Status update interface
   - Date range selection
   - Slot assignment

### Data Management:

1. Schedule States

   - EXPIRED: Red background
   - IN_PROGRESS: Green background
   - BOOKED: Gray background

2. API Integration
   - Fetch coach list
   - Get schedule by date range
   - Update schedule status
   - Create new schedule entries

### Features to Implement:

1. Schedule Creation

   - Select coach
   - Choose date range
   - Assign slots
   - Set initial status

2. Schedule Viewing

   - Calendar view
   - List view
   - Filter by coach/date/status
   - Search functionality

3. Schedule Management

   - Update status
   - Bulk updates
   - Cancel/Delete schedules
   - Override existing schedules

4. Validation & Alerts
   - Prevent invalid date selections
   - Confirmation for status changes
   - Warning for conflicting schedules
   - Error handling

### Mobile Responsiveness:

1. Adaptive calendar view
2. Responsive time slot grid
3. Touch-friendly controls
4. Mobile-optimized filters

Note: All changes will need approval before implementation.
