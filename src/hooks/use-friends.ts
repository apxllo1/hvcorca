import { useMemo } from "@rbxts/roact-hooked";
import { Players } from "@rbxts/services";
import { usePromise } from "hooks/common/use-promise";

export interface GameActivity {
	friends: FriendOnlineInfoGame[];
	placeId: number;
	thumbnail: string;
}

export function useFriends(deps?: unknown[]) {
	return usePromise(() => Players.LocalPlayer.GetFriendsOnline(), deps);
}

export function useFriendsPlaying(deps?: unknown[]) {
	const [friends, err, status] = useFriends(deps);

	const friendsPlaying = friends?.filter(
		(friend): friend is FriendOnlineInfoGame => "PlaceId" in friend && "GameId" in friend,
	);

	return [friendsPlaying, err, status] as const;
}

export function useFriendActivity(deps?: unknown[]) {
	const [friends, err, status] = useFriendsPlaying(deps);

	// Persistent array that only resets when deps change
	const games = useMemo(() => new Array<GameActivity>(), deps);

	// If there are no friends yet, or games already has data (deps didn't change),
	// don't rebuild the list.
	// eslint-disable-next-line roblox-ts/lua-truthiness
	if (!friends || games.size() !== 0) {
		return [games, err, status] as const;
	}

	friends.forEach((friend) => {
		let gameActivity = games.find((g) => g.placeId === friend.PlaceId);

		if (!gameActivity) {
			gameActivity = {
				friends: [friend] as FriendOnlineInfoGame[],
				placeId: friend.PlaceId,
				thumbnail: `https://www.roblox.com/asset-thumbnail/image?assetId=${friend.PlaceId}&width=768&height=432&format=png`,
			};
			games.push(gameActivity);
		} else {
			// eslint-disable-next-line @typescript-eslint/no-unsafe-argument
			gameActivity.friends.push(friend);
		}
	});

	return [games, err, status] as const;
}
