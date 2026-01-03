import { Schema, model, Types } from "mongoose";

const reportSchema = new Schema(
  {
    reporterId: { type: Types.ObjectId, ref: "User", required: true },
    targetType: { type: String, enum: ["post", "comment", "user"], required: true },
    targetId: { type: Types.ObjectId, required: true },
    reason: { type: String, required: true },
    description: { type: String },
    status: { type: String, enum: ["pending", "reviewed", "resolved", "dismissed"], default: "pending" },
    resolvedBy: { type: Types.ObjectId, ref: "User" },
    resolvedAt: { type: Date },
    resolution: { type: String },
  },
  { timestamps: true }
);

reportSchema.index({ status: 1, createdAt: -1 });
reportSchema.index({ targetType: 1, targetId: 1 });

export const Report = model("Report", reportSchema);
