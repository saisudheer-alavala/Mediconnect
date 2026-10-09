"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.doctorRoutes = void 0;
const express_1 = require("express");
const doctor_controller_1 = require("../controllers/doctor.controller");
const review_controller_1 = require("../controllers/review.controller");
const schedule_controller_1 = require("../controllers/schedule.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const review_validator_1 = require("../validators/review.validator");
const schedule_validator_1 = require("../validators/schedule.validator");
const router = (0, express_1.Router)();
// Doctor directory can be queried by authenticated users (patients, doctors, admin)
router.use(auth_middleware_1.authenticateJwt);
// Specific routes before parameterized /:id
router.get('/specializations', (req, res) => doctor_controller_1.doctorController.getSpecializations(req, res));
// Practitioner working hours schedule management
router.get('/me/schedule', (req, res) => schedule_controller_1.scheduleController.getMySchedule(req, res));
router.put('/me/schedule', (0, validate_middleware_1.validateRequest)(schedule_validator_1.updateScheduleSchema), (req, res) => schedule_controller_1.scheduleController.updateMySchedule(req, res));
// Directory listing with search & filters
router.get('/', (req, res) => doctor_controller_1.doctorController.getDoctors(req, res));
// Doctor details & slot templates
router.get('/:id', (req, res) => doctor_controller_1.doctorController.getDoctorById(req, res));
router.get('/:id/available-slots', (req, res) => doctor_controller_1.doctorController.getAvailableSlots(req, res));
// Doctor reviews & rating breakdown
router.get('/:doctorId/reviews', (req, res) => review_controller_1.reviewController.getDoctorReviews(req, res));
router.get('/:doctorId/rating-summary', (req, res) => review_controller_1.reviewController.getDoctorRatingSummary(req, res));
router.post('/:doctorId/reviews', (0, validate_middleware_1.validateRequest)(review_validator_1.createReviewSchema), (req, res) => review_controller_1.reviewController.submitReview(req, res));
exports.doctorRoutes = router;
