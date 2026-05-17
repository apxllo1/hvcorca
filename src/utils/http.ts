import { HttpService } from "@rbxts/services";
import { IS_DEV } from "constants";

export async function request(requestOptions: RequestAsyncRequest): Promise<RequestAsyncResponse> {
	if (IS_DEV) {
		return HttpService.RequestAsync(requestOptions);
	}

	// Try executor-injected globals in order of preference
	const executorRequest =
		(syn !== undefined ? syn.request : undefined) ??
		(typeof request === "function" ? (request as unknown as typeof syn.request) : undefined) ??
		(http !== undefined && http.request !== undefined ? http.request : undefined);

	if (executorRequest !== undefined) {
		return executorRequest(requestOptions);
	}

	throw "No suitable request function found (syn.request / request / http.request)";
}

export function get(url: string): Promise<string> {
	return new Promise((resolve, reject) => {
		task.spawn(() => {
			try {
				// game:HttpGet works on Medium, Velocity, and most modern executors
				const body = game.HttpGet(url);
				resolve(body);
			} catch (err: unknown) {
				reject(err);
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
				reject(err);
			}
		});
	});
}
