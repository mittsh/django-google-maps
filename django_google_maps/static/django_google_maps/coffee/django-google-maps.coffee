class GoogleMapsPicker
	
	constructor: (mapCanvas) ->
		
		@mapCanvas = mapCanvas
		@geolocationField = document.getElementById @mapCanvas.getAttribute 'data-field-id'
		@enableClickToPick = (@mapCanvas.getAttribute 'data-enable-click-to-pick') == 'true'
		@geolocationAddressField = document.getElementById @mapCanvas.getAttribute 'data-address-field-id'
		
		# Read the LatLng from input field
		latLng = @latLngFromField()
		
		# Initialize the Map
		@map = new google.maps.Map this.mapCanvas,
			center: latLng
			zoom: 8
			mapTypeId: google.maps.MapTypeId.ROADMAP
		
		# Initialize the draggable Marker
		@marker = new google.maps.Marker
			map: @map,
			draggable: true,
			position: latLng
		
		# Bind input field event 'focusout'
		$(@geolocationField).focusout () =>
			latLng = @latLngFromField()
			@map.setCenter latLng
			@marker.setPosition latLng
		
		# If click-to-pick is enabled, bind Map 'click' event
		if @enableClickToPick
			google.maps.event.addListener @map, 'click',  (event) =>
				@marker.setPosition event.latLng
				@latLngToField event.latLng
		
		# Bind marker 'drag' event
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

initializeGoogleMaps = () ->
	$('.map_canvas').each (index) ->
		picker = new GoogleMapsPicker @

google.maps.event.addDomListener window, 'load', initializeGoogleMaps
