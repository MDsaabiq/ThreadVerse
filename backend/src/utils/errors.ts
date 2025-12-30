export class ApiError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

export function badRequest(message: string) {
  return new ApiError(400, message);
}

export function unauthorized(message = "Unauthorized") {
  return new ApiError(401, message);
}

export function forbidden(message = "Forbidden") {
  return new ApiError(403, message);
}

export function notFound(message = "Not found") {
  return new ApiError(404, message);
}
