//////////////////////////////////////////////////////////
//              wice_grid_init.js.coffee                //
//////////////////////////////////////////////////////////
var focusElementIfNeeded, getGridProcessorForElement, initWiceGrid, moveDateBoundIfInvalidPeriod, setupAutoreloadsForExternalFilters, setupAutoreloadsForInternalFilters, setupBulkToggleForActionColumn, setupCsvExport, setupDatepicker, setupExternalCsvExport, setupExternalSubmitReset, setupHidingShowingOfFilterRow, setupMultiSelectToggle, setupShowingAllRecords, setupSubmitReset;

$(document).on('page:load ready', function() {
  return initWiceGrid();
});

initWiceGrid = function() {
  $(".wice-grid-container").each(function(index, wiceGridContainer) {
    var dataDiv, filterDeclaration, filterDeclarations, gridName, gridProcessor, processorInitializerArguments, _fn, _i, _len;
    gridName = wiceGridContainer.id;
    dataDiv = $(".wg-data", wiceGridContainer);
    processorInitializerArguments = dataDiv.data("processor-initializer-arguments");
    filterDeclarations = dataDiv.data("filter-declarations");
    focusElementIfNeeded(dataDiv.data("foc"));
    gridProcessor = new WiceGridProcessor(gridName, processorInitializerArguments[0], processorInitializerArguments[1], processorInitializerArguments[2], processorInitializerArguments[3], processorInitializerArguments[4], processorInitializerArguments[5]);
    _fn = function(filterDeclaration) {
      return gridProcessor.register({
        filterName: filterDeclaration.filterName,
        detached: filterDeclaration.detached,
        templates: filterDeclaration.declaration.templates,
        ids: filterDeclaration.declaration.ids
      });
    };
    for (_i = 0, _len = filterDeclarations.length; _i < _len; _i++) {
      filterDeclaration = filterDeclarations[_i];
      _fn(filterDeclaration);
    }
    window[gridName] = gridProcessor;
    setupDatepicker();
    setupSubmitReset(wiceGridContainer, gridProcessor);
    setupCsvExport(wiceGridContainer, gridProcessor);
    setupHidingShowingOfFilterRow(wiceGridContainer);
    setupShowingAllRecords(wiceGridContainer, gridProcessor);
    setupMultiSelectToggle(wiceGridContainer);
    setupAutoreloadsForInternalFilters(wiceGridContainer, gridProcessor);
    return setupBulkToggleForActionColumn(wiceGridContainer);
  });
  setupAutoreloadsForExternalFilters();
  setupExternalSubmitReset();
  setupExternalCsvExport();
  return setupMultiSelectToggle($('.wg-detached-filter'));
};

moveDateBoundIfInvalidPeriod = function(dataFieldNameWithTheOtherDatepicker, datepickerHiddenField, selectedDate, dateFormat, predicate) {
  var datepickerId, theOtherDate, theOtherDatepicker, _datepickerId;
  if ((datepickerId = datepickerHiddenField.data(dataFieldNameWithTheOtherDatepicker)) && (theOtherDatepicker = $(_datepickerId = "#" + datepickerId)) && (theOtherDate = theOtherDatepicker.datepicker('getDate')) && predicate(theOtherDate, selectedDate)) {
    theOtherDatepicker.datepicker("setDate", selectedDate);
    return theOtherDatepicker.next().next().html($.datepicker.formatDate(dateFormat, selectedDate));
  }
};

setupDatepicker = function() {
  var locale;
  if ($('.wice-grid-container input.check-for-datepicker[type=hidden], .wg-detached-filter input.check-for-datepicker[type=hidden]').length !== 0) {
    if (!$.datepicker) {
      alert("Seems like you do not have jQuery datepicker (http://jqueryui.com/demos/datepicker/)\ninstalled. Either install it or set Wice::Defaults::HELPER_STYLE to :standard in\nwice_grid_config.rb in order to use standard Rails date helpers");
    }
  }
  if (locale = $('.wice-grid-container input[type=hidden], .wg-detached-filter input[type=hidden]').data('locale')) {
    $.datepicker.setDefaults($.datepicker.regional[locale]);
  }
  return $('.wice-grid-container .date-label, .wg-detached-filter .date-label').each(function(index, removeLink) {
    var dateFormat, datepickerHiddenField, eventToTriggerOnChange, that, yearRange;
    datepickerHiddenField = $('#' + $(removeLink).data('dom-id'));
    eventToTriggerOnChange = datepickerHiddenField.data('close-calendar-event-name');
    $(removeLink).click(function(event) {
      $(this).html('');
      datepickerHiddenField.val('');
      if (eventToTriggerOnChange) {
        datepickerHiddenField.trigger(eventToTriggerOnChange);
      }
      event.preventDefault();
      return false;
    });
    that = this;
    dateFormat = datepickerHiddenField.data('date-format');
    yearRange = datepickerHiddenField.data('date-year-range');
    return datepickerHiddenField.datepicker({
      firstDay: 1,
      showOn: "button",
      dateFormat: dateFormat,
      buttonImage: datepickerHiddenField.data('button-image'),
      buttonImageOnly: true,
      buttonText: datepickerHiddenField.data('button-text'),
      changeMonth: true,
      changeYear: true,
      yearRange: yearRange,
      onSelect: function(dateText, inst) {
        var selectedDate;
        selectedDate = $(this).datepicker("getDate");
        moveDateBoundIfInvalidPeriod('the-other-datepicker-id-to', datepickerHiddenField, selectedDate, dateFormat, function(theOther, selected) {
          return theOther < selected;
        });
        moveDateBoundIfInvalidPeriod('the-other-datepicker-id-from', datepickerHiddenField, selectedDate, dateFormat, function(theOther, selected) {
          return theOther > selected;
        });
        $(that).html(dateText);
        if (eventToTriggerOnChange) {
          return datepickerHiddenField.trigger(eventToTriggerOnChange);
        }
      }
    });
  });
};

setupHidingShowingOfFilterRow = function(wiceGridContainer) {
  var filterRow, hideFilter, showFilter;
  hideFilter = '.wg-hide-filter';
  showFilter = '.wg-show-filter';
  filterRow = '.wg-filter-row';
  $(hideFilter, wiceGridContainer).click(function() {
    $(this).hide();
    $(showFilter, wiceGridContainer).show();
    return $(filterRow, wiceGridContainer).hide();
  });
  return $(showFilter, wiceGridContainer).click(function() {
    $(this).hide();
    $(hideFilter, wiceGridContainer).show();
    return $(filterRow, wiceGridContainer).show();
  });
};

setupCsvExport = function(wiceGridContainer, gridProcessor) {
  return $('.export-to-csv-button', wiceGridContainer).click(function() {
    return gridProcessor.exportToCsv();
  });
};

setupSubmitReset = function(wiceGridContainer, gridProcessor) {
  $('.submit', wiceGridContainer).click(function() {
    return gridProcessor.process();
  });
  $('.reset', wiceGridContainer).click(function() {
    return gridProcessor.reset();
  });
  return $('.wg-filter-row input[type=text]', wiceGridContainer).keydown(function(event) {
    if (event.keyCode === 13) {
      event.preventDefault();
      return gridProcessor.process();
    }
  });
};

focusElementIfNeeded = function(focusId) {
  var elToFocus, elements;
  elements = $('#' + focusId);
  if (elToFocus = elements[0]) {
    elToFocus.value = elToFocus.value;
    return elToFocus.focus();
  }
};

setupAutoreloadsForInternalFilters = function(wiceGridContainer, gridProcessor) {
  $('select.auto-reload', wiceGridContainer).change(function() {
    return gridProcessor.process();
  });
  $('input.auto-reload', wiceGridContainer).keyup(function() {
    return gridProcessor.setProcessTimer(this.id);
  });
  $('input.negation-checkbox.auto-reload', wiceGridContainer).click(function() {
    return gridProcessor.process();
  });
  return $(document).bind('wg:calendarChanged_' + gridProcessor.name, function() {
    return gridProcessor.process();
  });
};

setupAutoreloadsForExternalFilters = function() {
  return $('.wg-detached-filter').each(function(index, detachedFilterContainer) {
    var gridProcessor;
    gridProcessor = getGridProcessorForElement(detachedFilterContainer);
    if (gridProcessor) {
      $('select.auto-reload', detachedFilterContainer).change(function() {
        return gridProcessor.process();
      });
      $('input.auto-reload', detachedFilterContainer).keyup(function() {
        return gridProcessor.setProcessTimer(this.id);
      });
      return $('input.negation-checkbox.auto-reload', detachedFilterContainer).click(function() {
        return gridProcessor.process();
      });
    }
  });
};

setupShowingAllRecords = function(wiceGridContainer, gridProcessor) {
  return $('.wg-show-all-link, .wg-back-to-pagination-link', wiceGridContainer).click(function(event) {
    var confirmationMessage, gridState, reloadGrid;
    event.preventDefault();
    gridState = $(this).data("grid-state");
    confirmationMessage = $(this).data("confim-message");
    reloadGrid = function() {
      return gridProcessor.reloadPageForGivenGridState(gridState);
    };
    if (confirmationMessage) {
      if (confirm(confirmationMessage)) {
        return reloadGrid();
      }
    } else {
      return reloadGrid();
    }
  });
};

setupMultiSelectToggle = function(wiceGridContainer) {
  $('.expand-multi-select-icon', wiceGridContainer).click(function() {
    $(this).prev().each(function(index, select) {
      return select.multiple = true;
    });
    $(this).next().show();
    return $(this).hide();
  });
  return $('.collapse-multi-select-icon', wiceGridContainer).click(function() {
    $(this).prev().prev().each(function(index, select) {
      return select.multiple = false;
    });
    $(this).prev().show();
    return $(this).hide();
  });
};

setupBulkToggleForActionColumn = function(wiceGridContainer) {
  $('.select-all', wiceGridContainer).click(function() {
    return $('.sel input', wiceGridContainer).prop('checked', true).trigger('change');
  });
  return $('.deselect-all', wiceGridContainer).click(function() {
    return $('.sel input', wiceGridContainer).prop('checked', false).trigger('change');
  });
};

getGridProcessorForElement = function(element) {
  var gridName;
  gridName = $(element).data('grid-name');
  if (gridName) {
    return window[gridName];
  } else {
    return null;
  }
};

setupExternalCsvExport = function() {
  return $(".wg-external-csv-export-button").each(function(index, externalCsvExportButton) {
    var gridProcessor;
    gridProcessor = getGridProcessorForElement(externalCsvExportButton);
    if (gridProcessor) {
      return $(externalCsvExportButton).click(function(event) {
        return gridProcessor.exportToCsv();
      });
    }
  });
};

setupExternalSubmitReset = function() {
  $(".wg-external-submit-button").each(function(index, externalSubmitButton) {
    var gridProcessor;
    gridProcessor = getGridProcessorForElement(externalSubmitButton);
    if (gridProcessor) {
      return $(externalSubmitButton).click(function(event) {
        gridProcessor.process();
        event.preventDefault();
        return false;
      });
    }
  });
  $(".wg-external-reset-button").each(function(index, externalResetButton) {
    var gridProcessor;
    gridProcessor = getGridProcessorForElement(externalResetButton);
    if (gridProcessor) {
      return $(externalResetButton).click(function(event) {
        gridProcessor.reset();
        event.preventDefault();
        return false;
      });
    }
  });
  return $('.wg-detached-filter').each(function(index, detachedFilterContainer) {
    var gridProcessor;
    gridProcessor = getGridProcessorForElement(detachedFilterContainer);
    if (gridProcessor) {
      return $('input[type=text]', this).keydown(function(event) {
        if (event.keyCode === 13) {
          gridProcessor.process();
          event.preventDefault();
          return false;
        }
      });
    }
  });
};

window['getGridProcessorForElement'] = getGridProcessorForElement;


//////////////////////////////////////////////////////////
//            wice_grid_processor.js.coffee             //
//////////////////////////////////////////////////////////
var WiceGridProcessor;

WiceGridProcessor = (function() {
  function WiceGridProcessor(name, baseRequestForFilter, baseLinkForShowAllRecords, linkForExport, parameterNameForQueryLoading, parameterNameForFocus, environment) {
    this.name = name;
    this.baseRequestForFilter = baseRequestForFilter;
    this.baseLinkForShowAllRecords = baseLinkForShowAllRecords;
    this.linkForExport = linkForExport;
    this.parameterNameForQueryLoading = parameterNameForQueryLoading;
    this.parameterNameForFocus = parameterNameForFocus;
    this.environment = environment;
    this.filterDeclarations = new Array();
    this.checkIfJsFrameworkIsLoaded();
  }

  WiceGridProcessor.prototype.checkIfJsFrameworkIsLoaded = function() {
    if (!jQuery) {
      return alert("jQuery not loaded, WiceGrid cannot proceed!");
    }
  };

  WiceGridProcessor.prototype.toString = function() {
    return "<WiceGridProcessor instance for grid '" + this.name + "'>";
  };

  WiceGridProcessor.prototype.process = function(domIdToFocus) {
    return window.location = this.buildUrlWithParams(domIdToFocus);
  };

  WiceGridProcessor.prototype.setProcessTimer = function(domIdToFocus) {
    var processor;
    if (this.timer) {
      clearTimeout(this.timer);
      this.timer = null;
    }
    processor = this;
    return this.timer = setTimeout(function() {
      return processor.process(domIdToFocus);
    }, 1000);
  };

  WiceGridProcessor.prototype.reloadPageForGivenGridState = function(gridState) {
    var requestPath;
    requestPath = this.gridStateToRequest(gridState);
    return window.location = this.appendToUrl(this.baseLinkForShowAllRecords, requestPath);
  };

  WiceGridProcessor.prototype.gridStateToRequest = function(gridState) {
    return jQuery.map(gridState, function(pair) {
      return encodeURIComponent(pair[0]) + '=' + encodeURIComponent(pair[1]);
    }).join('&');
  };

  WiceGridProcessor.prototype.appendToUrl = function(url, str) {
    var sep;
    sep = url.indexOf('?') !== -1 ? /[&\?]$/.exec(url) ? '' : '&' : '?';
    return url + sep + str;
  };

  WiceGridProcessor.prototype.buildUrlWithParams = function(domIdToFocus) {
    var allFilterParams, res, results,
      _this = this;
    results = new Array();
    jQuery.each(this.filterDeclarations, function(i, filterDeclaration) {
      var param;
      param = _this.readValuesAndFormQueryString(filterDeclaration.filterName, filterDeclaration.detached, filterDeclaration.templates, filterDeclaration.ids);
      if (param && param !== '') {
        return results.push(param);
      }
    });
    res = this.baseRequestForFilter;
    if (results.length !== 0) {
      allFilterParams = results.join('&');
      res = this.appendToUrl(res, allFilterParams);
    }
    if (domIdToFocus) {
      res = this.appendToUrl(res, this.parameterNameForFocus + domIdToFocus);
    }
    return res;
  };

  WiceGridProcessor.prototype.reset = function() {
    return window.location = this.baseRequestForFilter;
  };

  WiceGridProcessor.prototype.exportToCsv = function() {
    return window.location = this.linkForExport;
  };

  WiceGridProcessor.prototype.register = function(func) {
    return this.filterDeclarations.push(func);
  };

  WiceGridProcessor.prototype.readValuesAndFormQueryString = function(filterName, detached, templates, ids) {
    var el, i, j, message, res, val, _i, _j, _ref, _ref1;
    res = new Array();
    for (i = _i = 0, _ref = templates.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if ($(ids[i]) === null) {
        if (this.environment === "development") {
          message = 'WiceGrid: Error reading state of filter "' + filterName + '". No DOM element with id "' + ids[i] + '" found.';
          if (detached) {
            message += 'You have declared "' + filterName + '" as a detached filter but have not output it anywhere in the template. Read documentation about detached filters.';
          }
          alert(message);
        }
        return '';
      }
      el = $('#' + ids[i]);
      if (el[0] && el[0].type === 'checkbox') {
        if (el[0].checked) {
          val = 1;
        }
      } else {
        val = el.val();
      }
      if (val instanceof Array) {
        for (j = _j = 0, _ref1 = val.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          if (val[j] && val[j] !== "") {
            res.push(templates[i] + encodeURIComponent(val[j]));
          }
        }
      } else if (val && val !== '') {
        res.push(templates[i] + encodeURIComponent(val));
      }
    }
    return res.join('&');
  };

  WiceGridProcessor;

  return WiceGridProcessor;

})();

WiceGridProcessor._version = '3.2';

window['WiceGridProcessor'] = WiceGridProcessor;


//////////////////////////////////////////////////////////
//       wice_grid_saved_queries_init.js.coffee         //
//////////////////////////////////////////////////////////
var deleteQuery, loadQuery, onChangeToQueryList, saveQuery, savedQueriesInit;

$(document).on('page:load ready', function() {
  return savedQueriesInit();
});

savedQueriesInit = function() {
  $('.wice-grid-save-query-field').keydown(function(event) {
    if (event.keyCode === 13) {
      return saveQuery($(this).next(), event);
    }
  });
  $(".wice-grid-save-query-button").click(function(event) {
    return saveQuery(this, event);
  });
  $(".wice-grid-delete-query").click(function(event) {
    return deleteQuery(this, event);
  });
  return $(".wice-grid-query-load-link").click(function(event) {
    return loadQuery(this, event);
  });
};

loadQuery = function(loadLink, event) {
  var gridProcessor, queryId, request;
  if (gridProcessor = window.getGridProcessorForElement(loadLink)) {
    queryId = $(loadLink).data('query-id');
    request = gridProcessor.appendToUrl(gridProcessor.buildUrlWithParams(), gridProcessor.parameterNameForQueryLoading + encodeURIComponent(queryId));
    window.location = request;
  }
  event.preventDefault();
  event.stopPropagation();
  return false;
};

deleteQuery = function(deleteQueryButton, event) {
  var confirmation, gridProcessor, invokeConfirmation;
  confirmation = $(deleteQueryButton).data('wg-confirm');
  invokeConfirmation = confirmation ? function() {
    return confirm(confirmation);
  } : function() {
    return true;
  };
  if (invokeConfirmation() && (gridProcessor = window.getGridProcessorForElement(deleteQueryButton))) {
    jQuery.ajax({
      url: $(deleteQueryButton).attr('href'),
      async: true,
      dataType: 'json',
      success: function(data, textStatus, jqXHR) {
        return onChangeToQueryList(data, gridProcessor.name);
      },
      type: 'POST'
    });
  }
  event.preventDefault();
  event.stopPropagation();
  return false;
};

saveQuery = function(saveQueryButton, event) {
  var basePathToQueryController, gridProcessor, gridState, inputField, inputIds, queryName, requestPath, _saveQueryButton;
  if (gridProcessor = window.getGridProcessorForElement(saveQueryButton)) {
    _saveQueryButton = $(saveQueryButton);
    basePathToQueryController = _saveQueryButton.data('base-path-to-query-controller');
    gridState = _saveQueryButton.data('parameters');
    inputIds = _saveQueryButton.data('ids');
    inputField = _saveQueryButton.prev();
    if (inputIds instanceof Array) {
      inputIds.each(function(domId) {
        return gridState.push(['extra[' + domId + ']', $('#' + domId).val()]);
      });
    }
    queryName = inputField.val();
    requestPath = gridProcessor.gridStateToRequest(gridState);
    jQuery.ajax({
      url: basePathToQueryController,
      async: true,
      data: requestPath + '&query_name=' + encodeURIComponent(queryName),
      dataType: 'json',
      success: function(data, textStatus, jqXHR) {
        return onChangeToQueryList(data, gridProcessor.name, queryName, inputField);
      },
      type: 'POST'
    });
    event.preventDefault();
    return false;
  }
};

onChangeToQueryList = function(data, gridName, queryName, inputField) {
  var errorMessages, gridTitleId, notificationMessages, notificationMessagesDomId, queryListId;
  notificationMessagesDomId = "#" + gridName + "_notification_messages";
  gridTitleId = "#" + gridName + "_title";
  queryListId = "#" + gridName + "_query_list";
  if (queryName) {
    inputField.val('');
  }
  if (errorMessages = data['error_messages']) {
    return $(notificationMessagesDomId).text(errorMessages);
  } else {
    if (notificationMessages = data['notification_messages']) {
      $(notificationMessagesDomId).text(notificationMessages);
    }
    if (queryName) {
      $(gridTitleId).html("<h3>" + queryName + "</h3>");
    }
    $(queryListId).replaceWith(data['query_list']);
    if (jQuery.ui) {
      $(queryListId).effect('highlight');
    }
    $(".wice-grid-delete-query", $(queryListId)).click(function(event) {
      return deleteQuery(this, event);
    });
    return $(".wice-grid-query-load-link", $(queryListId)).click(function(event) {
      return loadQuery(this, event);
    });
  }
};