class GoogleMapsPicker
	
	constructor: (mapCanvas) ->
		
		@mapCanvas = mapCanvas
		@geolocationField = document.getElementById @mapCanvas.getAttribute 'data-field-id'
		@geolocationAddressField = document.getElementById @mapCanvas.getAttribute 'data-address-field-id'
		
		enableClickToPick = (@mapCanvas.getAttribute 'data-enable-click-to-pick') == 'true'
		isAddressFieldTruth = false
		defaultMapZoom = parseInt (@mapCanvas.getAttribute 'data-default-map-zoom') or 8
		
		# Read the LatLng from input field
		latLng = @latLngFromField()
		
		# Initialize the Map
		@map = new google.maps.Map this.mapCanvas,
			center: latLng
			zoom: defaultMapZoom
			mapTypeId: google.maps.MapTypeId.ROADMAP
		
		# Initialize the draggable Marker
		@marker = new google.maps.Marker
			map: @map,
			draggable: true,
			position: latLng
		
		# Bind input field's event 'focusout'
		$(@geolocationField).focusout () =>
			latLng = @latLngFromField()
			@map.setCenter latLng
			@marker.setPosition latLng
			@reverseGeocodeToAddressField()
		
		# If click-to-pick is enabled, bind Map's 'click' event
		if enableClickToPick
			google.maps.event.addListener @map, 'click',  (event) =>
				@marker.setPosition event.latLng
				@latLngToField event.latLng
				@reverseGeocodeToAddressField()
		
		# Bind Marker's 'drag' event
		google.maps.event.addListener @marker, 'drag',  (event) =>
			@latLngToField event.latLng
		
		# When address field is provided, create a Geocoder
		if @geolocationAddressField
			
			# Initialize Geocoder
			@geocoder = new google.maps.Geocoder()
			
			# Bind address field 'focusout' event
			$(@geolocationAddressField).focusout (event) =>
				@geocodeFromAddressField()
			
			# Bind address field 'keydown' event (return key)
			$(@geolocationAddressField).keydown (event) =>
				if event.which == 13 # return key code is 13
					@geocodeFromAddressField()
					false
			
			# Bind Marker's 'dragend' event
			google.maps.event.addListener @marker, 'dragend', (event) =>
				@reverseGeocodeToAddressField()
		
		# If address field is not truth, set it's value from reverse geocoding
		if not isAddressFieldTruth
			@reverseGeocodeToAddressField()

	# Returns a LatLng object from the input field value
	latLngFromField: () ->
		[latitude, longitude,] = @geolocationField.value.split ','
		new google.maps.LatLng latitude or 0, longitude or 0
	
	# Sets the input field value to the given LatLng object
	latLngToField: (latLng) ->
		@geolocationField.value = "#{latLng.lat()},#{latLng.lng()}"
	
	# Geocodes the address from address field
	geocodeFromAddressField: () ->
		@geocoder.geocode
			'address': @geolocationAddressField.value,
			(results, status) =>
				if status == google.maps.GeocoderStatus.OK
					latLng = results[0].geometry.location
					@marker.setPosition latLng
					@latLngToField latLng
					@map.fitBounds results[0].geometry.viewport
	
	# Reverse-geocodes to the address field (if address field is provided)
	reverseGeocodeToAddressField: () ->
		if @geolocationAddressField
			@geocoder.geocode
				'latLng':@latLngFromField(),
				(results, status) =>
					if status == google.maps.GeocoderStatus.OK
						@geolocationAddressField.value = results[0].formatted_address

initializeGoogleMaps = () ->
	$('.map_canvas').each (index) ->
		picker = new GoogleMapsPicker @

google.maps.event.addDomListener window, 'load', initializeGoogleMaps
















