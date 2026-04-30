# Matatu SaaS API

A complete API for managing matatu (public transport) operations including companies, vehicles, routes, drivers, trips, fuel records, and expenses.

---

## Authentication

Most endpoints require a Bearer token in the Authorization header:

Authorization: Bearer <your-jwt-token>
Tokens are obtained from signup or login responses.

---

## Onboarding

### POST /api/onboarding/signup
Create a new company and admin user. No authentication required.

**Expected Params:**
- `company` → `name`
- `admin` → `name`, `email`, `password`, `password_confirmation`

```bash
curl -X POST http://localhost:3000/api/onboarding/signup \
  -H "Content-Type: application/json" \
  -d '{"company":{"name":"Test Matatu Ltd"},"admin":{"name":"Admin User","email":"admin@testmatatu.com","password":"SecurePass123!","password_confirmation":"SecurePass123!"}}'
Auth
POST /api/auth/login
Login with email and password. No authentication required.
Expected Params: Flat  email  and  password  (no nesting).curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@testmatatu.com","password":"SecurePass123!"}'
Users
GET /api/users/mecurl http://localhost:3000/api/users/me \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
GET /api/users
List all users. Admin only.curl http://localhost:3000/api/users \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
Create user. Admin only.curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -d '{"user":{"name":"John Driver","email":"driver@testmatatu.com","password":"DriverPass123!","password_confirmation":"DriverPass123!","role":"driver","status":"pending"}}'
Drivers
POST /api/drivers
Register driver. Admin only. Uses  "user"  key.curl -X POST http://localhost:3000/api/drivers \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -d '{"user":{"name":"John Driver","email":"driver@testmatatu.com","password":"DriverPass123!","password_confirmation":"DriverPass123!"}}'
PATCH /api/drivers/:id/approveApprove pending driver. Admin only.curl -X PATCH http://localhost:3000/api/drivers/13/approve \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
Vehicles
GET /api/vehiclescurl http://localhost:3000/api/vehicles \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
POST /api/vehiclescurl -X POST http://localhost:3000/api/vehicles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -d '{"vehicle":{"plate_number":"KBC 123A","capacity":14,"status":"active"}}'
Routes
GET /api/routescurl http://localhost:3000/api/routes \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
POST /api/routescurl -X POST http://localhost:3000/api/routes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -d '{"route":{"origin":"Nairobi CBD","destination":"Westlands"}}'
Shift Assignments
POST /api/shift_assignmentscurl -X POST http://localhost:3000/api/shift_assignments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ADMIN_TOKEN>" \
  -d '{"shift_assignment":{"vehicle_id":10,"driver_id":13,"status":"active"}}'
Trips
POST /api/trips
Start trip. Driver token.curl -X POST http://localhost:3000/api/trips \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <DRIVER_TOKEN>" \
  -d '{"trip":{"vehicle_id":10,"route_id":8,"cash_collected":5000}}'
PATCH /api/trips/:id/end_trip
End trip. Multipart form. Driver token.curl -X PATCH http://localhost:3000/api/trips/14/end_trip \
  -H "Authorization: Bearer <DRIVER_TOKEN>" \
  -F "cash_collected=5000" \
  -F "cash_proof_photo=@proof.jpg"
curl http://localhost:3000/api/trips/14/summary \
  -H "Authorization: Bearer <ADMIN_TOKEN>"
Fuel Records
POST /api/trips/:trip_id/fuel_records
Multipart form. Photo required.curl -X POST http://localhost:3000/api/trips/14/fuel_records \
  -H "Authorization: Bearer <DRIVER_TOKEN>" \
  -F "fuel_record[amount]=3000" \
  -F "fuel_record[pump_photo]=@pump.jpg"
/Expense Records
POST /api/trips/:trip_id/expense_recordscurl -X POST http://localhost:3000/api/trips/14/expense_records \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <DRIVER_TOKEN>" \
  -d '{"expense_record":{"description":"Tire repair","amount":1500}}'
Endpoint	Auth	Params Key	Notes	
`/api/onboarding/signup`	None	`company` + `admin`	Returns token	
`/api/auth/login`	None	Flat `email` + `password`	Returns token	
`/api/users`	Bearer	`user`	Admin only for POST	
`/api/drivers`	Bearer	`user` (not `driver`)	Status auto "pending"	
`/api/vehicles`	Bearer	`vehicle`	Soft delete on DELETE	
`/api/routes`	Bearer	`route`		
`/api/shift_assignments`	Bearer	`shift_assignment`	No time columns	
`/api/trips`	Bearer	`trip`		
`/api/trips/:id/end_trip`	Bearer	Flat params	Multipart form	
`/api/trips/:id/fuel_records`	Bearer	`fuel_record`	Photo required	
`/api/trips/:id/expense_records`	Bearer	`expense_record`		
