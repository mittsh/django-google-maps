class GoogleMapsPicker
	
	constructor: (mapCanvas) ->
		
		@mapCanvas = mapCanvas
		@geolocationField = document.getElementById @mapCanvas.getAttribute 'data-field-id'
		@geolocationAddressField = document.getElementById @mapCanvas.getAttribute 'data-address-field-id'
		
		enableClickToPick = (@mapCanvas.getAttribute 'data-enable-click-to-pick') == 'true'
		autoupdatesAddress = (@mapCanvas.getAttribute 'data-autoupdates-address') == 'true'
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
			
			if autoupdatesAddress
				@reverseGeocodeToAddressField()
		
		# If click-to-pick is enabled, bind Map's 'click' event
		if enableClickToPick
			google.maps.event.addListener @map, 'click',  (event) =>
				@marker.setPosition event.latLng
				@latLngToField event.latLng
				
				# Auto updates the address
				if autoupdatesAddress
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
			
			# Bind Marker's 'dragend' event to reverse-geocode
			if autoupdatesAddress
				google.maps.event.addListener @marker, 'dragend', (event) =>
					@reverseGeocodeToAddressField()
		
		# Set address field value from reverse geocoding
		if autoupdatesAddress
			@reverseGeocodeToAddressField()
		
		# If not automatically updates the address, add an Update button
		if not autoupdatesAddress
			updateAddressButton = document.createElement 'input'
			updateAddressButton.setAttribute 'value', 'Update address'
			updateAddressButton.setAttribute 'type', 'submit'
			updateAddressButton.setAttribute 'class', 'field_helper'
			$(@geolocationAddressField).after updateAddressButton
			$(updateAddressButton).click () =>
				@reverseGeocodeToAddressField()
				false
		
		# Make sure the address field has the class 'map_value_address'
		# It might not be the case when using another field as address
		$(@geolocationAddressField).parent().addClass 'map_value_address'

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
















