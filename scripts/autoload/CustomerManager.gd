extends Node

signal customer_spawned(customer: Customer)
signal customer_despawned(customer_id: String)

const CUSTOMER_SCENE: PackedScene = preload("res://scenes/world/Customer.tscn")

var _active_customers: Dictionary[String, Customer] = {}

func spawn_customer(
	profile: CustomerProfile,
	spawn_destination_id: StringName
) -> Customer:
	if profile == null or profile.customer_id.is_empty():
		push_error("CustomerManager: Customer profile requires an ID.")
		return null
	
	var existing_customer := _active_customers.get(profile.customer_id) as Customer
	if existing_customer != null and is_instance_valid(existing_customer):
		return existing_customer
	
	var spawn_destination := CustomerDestinationRegistry.get_destination(
		spawn_destination_id
	)
	var active_level := SceneManager.get_active_level()
	
	if spawn_destination == null or active_level == null:
		push_error("CustomerManager: Cannot spawn customer without a valid destination and level.")
		return null
	
	var customer := CUSTOMER_SCENE.instantiate() as Customer
	active_level.add_child(customer)
	customer.global_position = spawn_destination.global_position
	customer.initialize(profile)
	customer.activate()
	
	_active_customers[profile.customer_id] = customer
	customer.tree_exiting.connect(
		_on_customer_tree_exiting.bind(profile.customer_id, customer),
		CONNECT_ONE_SHOT
	)
	
	customer_spawned.emit(customer)
	return customer

func despawn_customer(customer_id: String) -> void:
	var customer := _active_customers.get(customer_id) as Customer
	
	if customer == null or not is_instance_valid(customer):
		_active_customers.erase(customer_id)
		return
	
	customer.begin_leaving()
	customer.mark_despawned()
	customer.queue_free()

func get_customer(customer_id: String) -> Customer:
	return _active_customers.get(customer_id) as Customer

func get_active_customer_count() -> int:
	return _active_customers.size()


func get_active_customer_ids() -> Array[String]:
	var customer_ids: Array[String] = []
	for customer_id in _active_customers.keys():
		customer_ids.append(String(customer_id))
	return customer_ids

func _on_customer_tree_exiting(
	customer_id: String,
	customer: Customer
) -> void:
	if _active_customers.get(customer_id) == customer:
		_active_customers.erase(customer_id)
		customer_despawned.emit(customer_id)
