class GoogleMapsPicker
	
	constructor: (mapCanvas) ->
		@mapCanvas = mapCanvas
		@geolocationField = document.getElementById @mapCanvas.getAttribute 'data-field-id'
		@enableClickToPick = (@mapCanvas.getAttribute 'data-enable-click-to-pick') == 'true'
		@geolocationAddressField = document.getElementById @mapCanvas.getAttribute 'data-address-field-id'
		
		latLng = @latLngFromField()
		
		@map = new google.maps.Map this.mapCanvas,
			center: latLng
			zoom: 8
			mapTypeId: google.maps.MapTypeId.ROADMAP
		
		@marker = new google.maps.Marker
			map: @map,
			draggable: true,
			position: latLng
		
		$(@geolocationField).focusout () =>
			latLng = @latLngFromField()
			@map.setCenter latLng
			@marker.setPosition latLng
		
		if @enableClickToPick
			google.maps.event.addListener @map, 'click',  (event) =>
				@marker.setPosition event.latLng
				@latLngToField event.latLng
		
		google.maps.event.addListener @marker, 'drag',  (event) =>
			@latLngToField event.latLng
		
		if @geolocationAddressField
			@geocoder = new google.maps.Geocoder()
			
			$(@geolocationAddressField).focusout (event) =>
				@geocodeFromAddressField()
			
			$(@geolocationAddressField).keydown (event) =>
				if event.which == 13
					@geocodeFromAddressField()
					false

	
	latLngFromField: () ->
		[latitude, longitude,] = @geolocationField.value.split ','
		latLng = new google.maps.LatLng latitude or 0, longitude or 0
	
	latLngToField: (latLng) ->
		@geolocationField.value = "#{latLng.lat()},#{latLng.lng()}"
	
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
