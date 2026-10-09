"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.reviewRoutes = void 0;
const express_1 = require("express");
const review_controller_1 = require("../controllers/review.controller");
const auth_middleware_1 = require("../middleware/auth.middleware");
const validate_middleware_1 = require("../middleware/validate.middleware");
const review_validator_1 = require("../validators/review.validator");
const router = (0, express_1.Router)();
router.use(auth_middleware_1.authenticateJwt);
// Review endpoints
router.get('/doctor/:doctorId', (req, res) => review_controller_1.reviewController.getDoctorReviews(req, res));
router.get('/doctor/:doctorId/summary', (req, res) => review_controller_1.reviewController.getDoctorRatingSummary(req, res));
router.post('/doctor/:doctorId', (0, validate_middleware_1.validateRequest)(review_validator_1.createReviewSchema), (req, res) => review_controller_1.reviewController.submitReview(req, res));
exports.reviewRoutes = router;
