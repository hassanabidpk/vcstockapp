import { Router } from "express";
import { portfoliosRouter } from "./portfolios.routes.js";
import { holdingsRouter } from "./holdings.routes.js";
import { stocksRouter } from "./stocks.routes.js";
import { cryptoRouter } from "./crypto.routes.js";

const router = Router();

router.use("/portfolios", portfoliosRouter);
router.use("/", holdingsRouter); // holdings routes have their own prefixes
router.use("/stocks", stocksRouter);
router.use("/crypto", cryptoRouter);

export { router as v1Router };
