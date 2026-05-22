import { HttpService } from "@rbxts/services";
import { IS_DEV } from "constants";

export function request(requestOptions: RequestAsyncRequest): Promise<RequestAsyncResponse> {
	if (IS_DEV) {
		return Promise.resolve(HttpService.RequestAsync(requestOptions));
	}

	const executorRequest =
		syn !== undefined && syn.request !== undefined
			? syn.request
			: typeIs(rawget(_G, "request"), "function")
				? (rawget(_G, "request") as (req: RequestAsyncRequest) => RequestAsyncResponse)
				: http !== undefined && http.request !== undefined
					? http.request
					: undefined;

	if (executorRequest !== undefined) {
		return Promise.resolve(executorRequest(requestOptions));
	}

	return Promise.reject(
		"No suitable request function found (syn.request / request / http.request)",
	) as Promise<RequestAsyncResponse>;
}

export function get(url: string): Promise<string> {
	return new Promise((resolve, reject) => {
		task.spawn(() => {
			try {
				const body = (game as unknown as { HttpGet: (url: string) => string }).HttpGet(url);
				resolve(body);
			} catch (err: unknown) {
				reject(tostring(err));
			}
		});
	});
}

export function post(
	url: string,
	data: string,
	contentType?: string,
	requestType?: Enum.HttpRequestType,
): Promise<string> {
	return new Promise((resolve, reject) => {
		task.spawn(() => {
			try {
				const body = game.HttpPostAsync(url, data, contentType, requestType);
				resolve(body);
			} catch (err: unknown) {
				reject(tostring(err));
			}
		});
	});
}
