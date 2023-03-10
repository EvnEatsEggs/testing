/obj/item/paper/fluff/jobs/cargo/manifest
	var/order_cost = 0
	var/order_id = 0

/obj/item/paper/fluff/jobs/cargo/manifest/New(atom/A, id, cost)
	..()
	order_id = id
	order_cost = cost

/datum/supply_order
	var/id
	var/orderer
	var/orderer_rank
	var/orderer_ckey
	var/reason
	var/datum/supply_pack/pack
	var/datum/bank_account/paying_account

/datum/supply_order/New(datum/supply_pack/pack, orderer, orderer_rank, orderer_ckey, reason, paying_account)
	id = SSshuttle.ordernum++
	src.pack = pack
	src.orderer = orderer
	src.orderer_rank = orderer_rank
	src.orderer_ckey = orderer_ckey
	src.reason = reason
	src.paying_account = paying_account

/datum/supply_order/proc/generateRequisition(turf/T)
	var/obj/item/paper/P = new(T)

	P.name = "requisition form - #[id] ([pack.name])"
	P.info += "<h2>[station_name()] Supply Requisition</h2>"
	P.info += "<hr/>"
	P.info += "Order #[id]<br/>"
	P.info += "Time of Order: [station_time_timestamp()]<br/>"
	P.info += "Item: [pack.name]<br/>"
	P.info += "Requested by: [orderer]<br/>"
	if(paying_account)
		P.info += "Paid by: [paying_account.account_holder]<br/>"
	P.info += "Rank: [orderer_rank]<br/>"
	P.info += "Comment: [reason]<br/>"

	P.update_icon()
	return P

/datum/supply_order/proc/generateManifest(obj/structure/closet/crate/C, owner, packname) //generates-the-manifests.
	var/obj/item/paper/fluff/jobs/cargo/manifest/P = new(C, id, 0)

	P.name = "shipping manifest - [packname?"#[id] ([pack.name])":"(Grouped Item Crate)"]"
	P.info += "<h2>[command_name()] Shipping Manifest</h2>"
	P.info += "<hr/>"
	if(owner && !(owner == "Cargo"))
		P.info += "Direct purchase from [owner]<br/>"
		P.name += " - Purchased by [owner]"
	P.info += "Order[packname?"":"s"]: [id]<br/>"
	P.info += "Destination: [station_name()]<br/>"
	if(packname)
		P.info += "Item: [packname]<br/>"
	P.info += "Contents: <br/>"
	P.info += "<ul>"
	for(var/atom/movable/AM in C.contents - P)
		P.info += "<li>[AM.name]</li>"
	P.info += "</ul>"
	P.info += "<h4>Stamp below to confirm receipt of goods:</h4>"

	P.update_icon()
	P.forceMove(C)
	C.manifest = P
	C.update_icon()

	return P

/datum/supply_order/proc/generate(atom/A)
	var/account_holder
	if(paying_account)
		account_holder = paying_account.account_holder
	else
		account_holder = "Cargo"
	var/obj/structure/closet/crate/C = pack.generate(A, paying_account)
	generateManifest(C, account_holder, pack)
	return C

/datum/supply_order/proc/generateCombo(miscbox, misc_own, misc_contents)
	for (var/I in misc_contents)
		new I(miscbox)
	generateManifest(miscbox, misc_own, "")
	return