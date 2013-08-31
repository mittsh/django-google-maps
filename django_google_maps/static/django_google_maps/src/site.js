// Generated by CoffeeScript 1.6.3
(function() {
  var GoogleMapsPicker, initializeGoogleMaps;

  GoogleMapsPicker = (function() {
    function GoogleMapsPicker(mapCanvas) {
      var defaultMapZoom, enableClickToPick, isAddressFieldTruth, latLng,
        _this = this;
      this.mapCanvas = mapCanvas;
      this.geolocationField = document.getElementById(this.mapCanvas.getAttribute('data-field-id'));
      this.geolocationAddressField = document.getElementById(this.mapCanvas.getAttribute('data-address-field-id'));
      enableClickToPick = (this.mapCanvas.getAttribute('data-enable-click-to-pick')) === 'true';
      isAddressFieldTruth = false;
      defaultMapZoom = parseInt((this.mapCanvas.getAttribute('data-default-map-zoom')) || 8);
      latLng = this.latLngFromField();
      this.map = new google.maps.Map(this.mapCanvas, {
        center: latLng,
        zoom: defaultMapZoom,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
      this.marker = new google.maps.Marker({
        map: this.map,
        draggable: true,
        position: latLng
      });
      $(this.geolocationField).focusout(function() {
        latLng = _this.latLngFromField();
        _this.map.setCenter(latLng);
        _this.marker.setPosition(latLng);
        return _this.reverseGeocodeToAddressField();
      });
      if (enableClickToPick) {
        google.maps.event.addListener(this.map, 'click', function(event) {
          _this.marker.setPosition(event.latLng);
          _this.latLngToField(event.latLng);
          return _this.reverseGeocodeToAddressField();
        });
      }
      google.maps.event.addListener(this.marker, 'drag', function(event) {
        return _this.latLngToField(event.latLng);
      });
      if (this.geolocationAddressField) {
        this.geocoder = new google.maps.Geocoder();
        $(this.geolocationAddressField).focusout(function(event) {
          return _this.geocodeFromAddressField();
        });
        $(this.geolocationAddressField).keydown(function(event) {
          if (event.which === 13) {
            _this.geocodeFromAddressField();
            return false;
          }
        });
        google.maps.event.addListener(this.marker, 'dragend', function(event) {
          return _this.reverseGeocodeToAddressField();
        });
      }
      if (!isAddressFieldTruth) {
        this.reverseGeocodeToAddressField();
      }
    }

    GoogleMapsPicker.prototype.latLngFromField = function() {
      var latitude, longitude, _ref;
      _ref = this.geolocationField.value.split(','), latitude = _ref[0], longitude = _ref[1];
      return new google.maps.LatLng(latitude || 0, longitude || 0);
    };

    GoogleMapsPicker.prototype.latLngToField = function(latLng) {
      return this.geolocationField.value = "" + (latLng.lat()) + "," + (latLng.lng());
    };

    GoogleMapsPicker.prototype.geocodeFromAddressField = function() {
      var _this = this;
      return this.geocoder.geocode({
        'address': this.geolocationAddressField.value
      }, function(results, status) {
        var latLng;
        if (status === google.maps.GeocoderStatus.OK) {
          latLng = results[0].geometry.location;
          _this.marker.setPosition(latLng);
          _this.latLngToField(latLng);
          return _this.map.fitBounds(results[0].geometry.viewport);
        }
      });
    };

    GoogleMapsPicker.prototype.reverseGeocodeToAddressField = function() {
      var _this = this;
      if (this.geolocationAddressField) {
        return this.geocoder.geocode({
          'latLng': this.latLngFromField()
        }, function(results, status) {
          if (status === google.maps.GeocoderStatus.OK) {
            return _this.geolocationAddressField.value = results[0].formatted_address;
          }
        });
      }
    };

    return GoogleMapsPicker;

  })();

  initializeGoogleMaps = function() {
    return $('.map_canvas').each(function(index) {
      var picker;
      return picker = new GoogleMapsPicker(this);
    });
  };

  google.maps.event.addDomListener(window, 'load', initializeGoogleMaps);

}).call(this);
