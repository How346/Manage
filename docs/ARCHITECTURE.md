# Architecture

- `models/`: immutable data objects and map conversion.
- `database/`: one SQLite gateway; SQL stays out of widgets.
- `services/`: device integrations (notifications, media, WhatsApp).
- `providers/`: application state and orchestration.
- `views/`: screens and form flows.
- `widgets/`: reusable presentation components.

## Data integrity
- Foreign keys are enabled on every database connection.
- Fee and salary records use `(owner_id, month_year)` uniqueness.
- Fee status is derived from total/paid at write time.
- Deleting a student/teacher cascades their child financial records.
- All SQL values are parameterized.
- WAL mode is enabled for better reliability.

## Offline boundary
There is no remote API. WhatsApp is deliberately an external hand-off and does not upload school records to a school server. The user controls whether the external app opens.

## Production hardening before Play release
- Replace default launcher icon and app display name.
- Add a branded privacy policy and data-retention statement.
- Configure Android backup policy according to the school's privacy requirements.
- Add encrypted export/restore if school administrators need device migration.
- Add authentication/biometric lock if the device can be shared.
- Add audit logs for destructive or financial actions.
- Test notification behavior on the target Android OEMs and battery-optimization settings.
