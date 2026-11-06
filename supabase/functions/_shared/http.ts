export interface ApiErrorBody {
  readonly error: {
    readonly code: string;
    readonly message: string;
    readonly request_id: string;
  };
}

export function jsonResponse(
  body: unknown,
  status = 200,
  headers: HeadersInit = {},
): Response {
  return Response.json(body, {
    status,
    headers: {
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff",
      ...headers,
    },
  });
}

export function errorResponse(
  code: string,
  message: string,
  status: number,
  requestId: string,
  headers: HeadersInit = {},
): Response {
  const body: ApiErrorBody = {
    error: {
      code,
      message,
      request_id: requestId,
    },
  };
  return jsonResponse(body, status, headers);
}
