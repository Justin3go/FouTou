import { createRouter, createWebHistory } from "vue-router";
import Start from "../pages/Start.vue";
import { useEtherStore } from "@/store/etherStore";

let etherStore: any = null;
const routes = [
	{
		path: "/",
		name: "start",
		component: Start,
	},
	{
		path: "/browse",
		name: "browse",
		component: () => import("../pages/Browse.vue"),
	},
	{
		path: "/personal",
		name: "personal",
		component: () => import("../pages/Personal.vue"),
	},
	{
		path: "/create",
		name: "create",
		component: () => import("../pages/Create.vue"),
	},
];

const router = createRouter({
	history: createWebHistory(import.meta.env.BASE_URL),
	routes,
});

router.beforeEach((to, from) => {
	if (etherStore === null) {
		etherStore = useEtherStore();
	}
  if(!etherStore.account){
    ElMessage({
			showClose: true,
			message: "未获取账户信息，请到【其他>连接钱包】中操作",
			type: "error",
		});
  }
	console.log(etherStore.account);
});

export default router;
