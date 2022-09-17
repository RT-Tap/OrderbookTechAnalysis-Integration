conn = new Mongo();
db = conn.getDB("admin");
db.auth(process.env.MONGO_INITDB_ROOT_USERNAME, process.env.MONGO_INITDB_ROOT_PASSWORD);
db = db.getSiblingDB('orderbook&trades');
db.createCollection("marketOne", {autoIndexId: false} );
db.marketOne.insertOne({_id:123456, Notes: "this is a placeholder entry in order to setup our environment ", "orberbookBids":[[0.1,0.1],[0.2,0.2]],"orderbookAsks":[[0.3,0.3],[0.4,0.4]],"buys":[[0.5,0.5],[0.6,0.6]],"sells":[[0.7,0.7],[0.8,0.8]]});
db = db.getSiblingDB('demo-otherMarketData');
db.createCollection("marketTwo", {autoIndexId: false} );
db.marketOne.insertOne({_id:123456, Notes: "this is a placeholder entry in order to setup our environment ", "orberbookBids":[[0.1,0.1],[0.2,0.2]],"orderbookAsks":[[0.3,0.3],[0.4,0.4]],"buys":[[0.5,0.5],[0.6,0.6]],"sells":[[0.7,0.7],[0.8,0.8]]});