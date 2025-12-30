import { Schema, model, Types } from "mongoose";

const commentSchema = new Schema(
  {
    postId: { type: Types.ObjectId, ref: "Post", required: true, index: true },
    parentCommentId: { type: Types.ObjectId, ref: "Comment" },
    authorId: { type: Types.ObjectId, ref: "User", required: true, index: true },
    content: { type: String, required: true },
    depth: { type: Number, default: 0 },
    voteScore: { type: Number, default: 0 },
    upvoteCount: { type: Number, default: 0 },
    downvoteCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

export const Comment = model("Comment", commentSchema);
