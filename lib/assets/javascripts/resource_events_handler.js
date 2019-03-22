function ResourceEventsHandler(settings) {
  // Initial state of the helper
  this._resource      = settings.resource;
  this._resources     = pluralize(this._resource);
  this._parent        = settings.parent;
  this._container     = settings.container  || '.content';
  this._containers    = settings.containers || [this._container];
  this._polymorphic   = settings.polymorphic;
  this._containerType = settings.containerType;
  this._attachable    = settings.attachable;
  this._placeholder   = settings.placeholder;

  // Selectors
  if (this._placeholder) {
    this._placeholderSelector = '.' + this._resources + '-placeholder';
  }
  this._contentSelector    = '.' + this._resource + '-content';
  this._editFormSelector   = '.edit-'   + this._resource;
  this._newFormSelector    = '.new-'    + this._resource;
  this._editResourceLink   = '.edit-'   + this._resource + '-link';
  this._newResourceLink    = '.new-'    + this._resource + '-link';
  this._deleteResourceLink = '.delete-' + this._resource + '-link';

  // Current events' containers
  this._eventsContainers = {};
}

// External interface
ResourceEventsHandler.prototype.handleEvent = function(properties) {
  var argument  = properties.argument;
  var eventName = properties.eventName;
  var self = this;
  if (properties.container) {
    this._eventsContainers[eventName] = properties.container;
    this[eventName].call(this, properties.container, argument);
  } else {
    this._eventsContainers[eventName] = this._containers.length > 1 ? this._containers
                                                                    : this._container;
    this._containers.forEach(function(container) {
      self[eventName].call(self, container, argument);
    })
  }
};

ResourceEventsHandler.prototype.handleEvents = function(properties) {
  var self = this;
  properties.eventsNames && properties.eventsNames.forEach(function(eventName) {
    self.handleEvent({
      eventName: eventName,
      container: properties.container,
      argument:  properties.argument
    });
  });
};

ResourceEventsHandler.prototype.handleNewFormToggleEvent = function(container) {
  this.handleEvent({
    eventName: '_newFormToggleEvent',
    container: container
  });
  return this;
};

ResourceEventsHandler.prototype.handleEditFormToggleEvent = function(container) {
  this.handleEvent({
    eventName: '_editFormToggleEvent',
    container: container
  });
  return this;
};

ResourceEventsHandler.prototype.handleAjaxCreateEvents = function(container) {
  this.handleEvents({
    eventsNames: ['_ajaxCreateSuccessEvent', '_ajaxFormErrorEvent'],
    container:   container,
    argument:    this._newFormSelector
  });
  return this;
};

ResourceEventsHandler.prototype.handleAjaxUpdateEvents = function(container) {
  this.handleEvents({
    eventsNames: ['_ajaxUpdateSuccessEvent', '_ajaxFormErrorEvent'],
    container:   container,
    argument:    this._editFormSelector
  });
  return this;
};

ResourceEventsHandler.prototype.handleAjaxDeleteEvent = function(container) {
  this.handleEvent({
    eventName: '_ajaxDeleteEvent',
    container: container
  });
  return this;
};

// Inner interface

// Toggle events
ResourceEventsHandler.prototype._newFormToggleEvent = function(container) {
  var self = this;
  $(container).on('click', this._newResourceLink, function(event) {
    event.preventDefault();

    var current = $(this);
    var attributes = current.data();

    var data = App.utils.transformKeysToUndescore(attributes);
    var parentContainer = self._findParentContainer(data);
    var newForm = parentContainer.find(self._newFormSelector);

    var linkName = 'Add ' + self._resource;
    App.utils.toggleCancelLink(current, linkName);
    newForm.toggle();
  });
};

ResourceEventsHandler.prototype._editFormToggleEvent = function(container) {
  var self = this;
  $(container).on('click', this._editResourceLink, function(e) {
    e.preventDefault();

    var current    = $(this);
    var resourceId = current.data(self._resource + 'Id') || gon[self._resource + "_id"];
    var currentResource = self._findCurrentResource(resourceId);

    var content  = currentResource.find(self._contentSelector);
    var editForm = currentResource.find(self._editFormSelector);

    App.utils.toggleCancelLink(current, 'Edit');
    editForm.toggle();
    content.toggle();
  });
};

// AJAX events
ResourceEventsHandler.prototype._ajaxCreateSuccessEvent = function(container) {
  var self = this;
  $(container).on('ajax:success', this._newFormSelector, function(event) {
    $('#errors').remove();

    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var item = data[self._resource];
    var parentContainer = self._findParentContainer(item);
    var currentResource = self._findCurrentResource(item.id);

    if (!currentResource.length) {
      self._addItem(item);
    }
    if (self._eventsContainers._newFormToggleEvent) {
      self._hideNewForm(parentContainer);
    }
    self._clearNewFormInput(parentContainer);
    App.utils.updateFlash('success', data.message);
  });
};

ResourceEventsHandler.prototype._ajaxUpdateSuccessEvent = function(container) {
  var self = this;
  $(container).on('ajax:success', this._editFormSelector, function(event) {
    $('#errors').remove();

    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var item = data[self._resource];
    var currentResource = self._findCurrentResource(item.id);

    var content = currentResource.find(self._contentSelector);
    content.replaceWith(App.utils.render(self._resources + '/content', item));

    var form = currentResource.find(self._editFormSelector);
    form.replaceWith(App.utils.render(self._resources + '/form', item));

    var editLink = currentResource.find(self._editResourceLink);
    App.utils.toggleCancelLink(editLink, 'Edit');

    App.utils.updateFlash('success', data.message);
  });
};

ResourceEventsHandler.prototype._ajaxDeleteEvent = function(elem) {
  var self = this;
  $(elem).on('ajax:success', this._deleteResourceLink, function(event) {
    $('#errors').remove();

    var detail = event.detail;
    var data   = detail[0],
        status = detail[1],
        xhr    = detail[2];

    var item   = data[self._resource];
    var currentResource = self._findCurrentResource(item.id);
    currentResource.remove();

    var parentContainer = self._findParentContainer(item);
    var selector = '.' + self._resources + '-' + self._containerType;
    var listContainer = parentContainer.find(selector);
    var elems = listContainer.find('.' + self._resource);

    if (!elems.length) {
      var placeholderContainer = self._createResourcePlaceholder();
      listContainer.replaceWith(placeholderContainer);
    }

    App.utils.updateFlash('success', data.message);
  });
};

ResourceEventsHandler.prototype._ajaxFormErrorEvent = function(container, selector) {
  $(container).on('ajax:error', selector, function(event) {
    var detail = event.detail;
    var data   = detail[0];
    var errors = data.errors

    var messages = App.utils.render("common/errors", { messages: errors });
    var form = $(this);
    form.prepend(messages);
  });
};

// Util methods
ResourceEventsHandler.prototype._addItem = function(item) {
  var parentContainer = this._findParentContainer(item);
  var listSelector = this._createListSelector();
  var list = parentContainer.find(listSelector);
  if (!list.length) {
    this._addListContainer(parentContainer);
    list = parentContainer.find(listSelector);
  }

  var newItem = App.utils.render(this._resources + '/' + this._resource, item);
  list.append(newItem);
};

ResourceEventsHandler.prototype._addListContainer = function(parentContainer) {
  var listContainer = (this._containerType === 'table') ? App.utils.emptyTable(this._resources)
                                                        : App.utils.emptyList(this._resources);
  if (this._placeholder) {
    var placeholderContainer = parentContainer.find(this._placeholderSelector);
    placeholderContainer.replaceWith(listContainer);
  } else {
    var resourcesSelector  = '.' + this._resources;
    var resourcesContainer = parentContainer.find(resourcesSelector);
    resourcesContainer.prepend(listContainer);
  }
};

ResourceEventsHandler.prototype._clearNewFormInput = function(parentContainer) {
  var newForm = parentContainer.find(this._newFormSelector);
  var textareaSelector = 'textarea[name="' + this._resource + '[body]"]';
  var textarea = newForm.find(textareaSelector);
  textarea.val('');

  if (this._attachable) {
    var nestedFields = newForm.find('.nested-fields');
    nestedFields.remove();
  }
};

ResourceEventsHandler.prototype._createListSelector = function() {
  var listType = this._containerType === 'table' ? 'table tbody' : this._containerType;
  var selector = '.' + this._resources + '-' + listType;
  return selector;
};

ResourceEventsHandler.prototype._createResourcePlaceholder = function() {
  var placeholderClass     = this._resources + '-placeholder';
  var placeholderContainer = $('<p>', {class: placeholderClass}).append($('<i>'));
  placeholderContainer.find('i').text(this._placeholder);
  return placeholderContainer;
};

ResourceEventsHandler.prototype._hideNewForm = function(parentContainer) {
  var newForm  = parentContainer.find(this._newFormSelector);
  newForm.hide();

  var newLink  = parentContainer.find(this._newResourceLink);
  var linkName = 'Add ' + this._resource;
  App.utils.toggleCancelLink(newLink, linkName);
};

ResourceEventsHandler.prototype._hideEditForm = function(resourceContainer) {
  var contentSelector = '.' + this._resource + '-content';
  var content  = resourceContainer.find(contentSelector);
  var editForm = resourceContainer.find(this._editFormSelector);
  var editLink = resourceContainer.find(this._editResourceLink);

  content.show();
  editForm.hide();
  App.utils.toggleCancelLink(this._editLink, 'Edit');
};

ResourceEventsHandler.prototype._findCurrentResource = function(resourceId) {
  var resourcesSelector = '#' + this._resource + '-' + resourceId;
  return $(resourcesSelector);
};

ResourceEventsHandler.prototype._findParentContainer = function(data) {
  var parentSelector, parentId;
  if (this._polymorphic && this._parent) {
    var parentType = data[this._parent + '_type'].toLowerCase();
    parentId       = data[this._parent + '_id'];
    parentSelector = '#' + parentType + '-' + parentId;
  } else if (this._parent) {
    parentId       = data[this._parent + '_id'];
    parentSelector = '#' + this._parent + '-' + parentId;
  } else {
    parentSelector = '.content'
  }
  return $(parentSelector);
};
