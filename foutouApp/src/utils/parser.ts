/* PER_items
name:justin3go,
description:i am good,
avator:https://ipfs.io/ipfs/QmWx2XXpJpWKaxSDM1aptTLvXjAzQ82afvoUFT4LWB2cCv?filename=ava.jpg,
可选：
twitter:test123,
facebook:test234,
wechat:test345,
weibo:test456,
douyin:test567,
kuaishou:test678,
bilibili:...
首先以逗号分开每一个键值对，然后通过第一个冒号分开键和值
*/
interface PER_ITEMS {
	name: string;
	description: string;
	avator: string;
	[propName: string]: any;
}
/**
 * PER_items(string) ==> json
 * @param items 伪json化的string
 */
function parsePER_items(items: string): PER_ITEMS {
	const item = items.split(",");
	const res: PER_ITEMS = { name: "", description: "", avator: "" };
	item.forEach((v) => {
		let i = v.indexOf(":");
		let resKey = v.slice(1, i);
		let resVal = v.slice(i + 1);
		res[resKey] = resVal;
	});
	return res;
}
