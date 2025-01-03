import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../client_options.dart';
import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import 'algolia_client_extensions.dart';
import 'client_options.dart';
import 'facet_search_service.dart';

class AlgoliaFacetSearchService implements FacetSearchService {
  /// Creates [AlgoliaFacetSearchService] instance.
  AlgoliaFacetSearchService({
    required String applicationID,
    required String apiKey,
    ClientOptions? options,
  }) : this.create(algolia.SearchClient(
          appId: applicationID,
          apiKey: apiKey,
          options: createClientOptions(options),
        ));

  /// Creates [AlgoliaFacetSearchService] instance.
  AlgoliaFacetSearchService.create(
    this._client,
  ) : _log = algoliaLogger('FacetSearchService');

  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  @override
  Future<FacetSearchResponse> search(FacetSearchState state) async {
    _log.fine('run search with state: $state');
    try {
      final rawResponse = await _client.searchForFacetValues(
        indexName: state.searchState.indexName,
        facetName: state.facet,
        searchForFacetValuesRequest: algolia.SearchForFacetValuesRequest(
          facetQuery: state.facetQuery,
          facetFilters: state.searchState.facetFilters,
          facets: state.searchState.facets,
          query: state.searchState.query,
        ),
      );
      final response = rawResponse.toSearchResponse();
      _log.fine('received response: $response');
      return response;
    } catch (exception) {
      _log.severe('exception: $exception');
      throw _client.launderException(exception);
    }
  }
}
