import { Schema, model, Types } from "mongoose";

const communityReputationSchema = new Schema(
  {
    userId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    communityId: { type: Types.ObjectId, ref: "Community", required: true, index: true },
    postKarma: { type: Number, default: 0 },
    commentKarma: { type: Number, default: 0 },
    totalKarma: { type: Number, default: 0 },
    postsCount: { type: Number, default: 0 },
    commentsCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

// Compound index for efficient lookups
communityReputationSchema.index({ userId: 1, communityId: 1 }, { unique: true });

// Virtual for calculating total karma
communityReputationSchema.virtual('karma').get(function() {
  return this.postKarma + this.commentKarma;
});

export type CommunityReputationDocument = typeof communityReputationSchema extends infer S
  ? S extends Schema<infer T>
    ? T & { _id: Types.ObjectId }
    : never
  : never;

export const CommunityReputation = model("CommunityReputation", communityReputationSchema);
