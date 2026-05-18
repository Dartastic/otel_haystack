// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_haystack_suppression.dart';

const _tracerName = 'dartastic_otel_libs_haystack';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class HaystackResult {
  const HaystackResult({
    this.pipelineName,
    this.componentName,
    this.componentKind,
    this.docStoreKind,
    this.documentCount,
    this.queryLength,
    this.topK,
    this.retrievedCount,
    this.scoreThreshold,
    this.minScore,
    this.maxScore,
    this.generatorProvider,
    this.generatorModel,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.maxLoops,
    this.loopCount,
    this.connectionCount,
    this.deepsetCloudWorkspace,
    this.errorKind,
    this.errorMessage,
  });

  /// Pipeline identifier (developer-named).
  final String? pipelineName;

  /// Component instance name.
  final String? componentName;

  /// `BM25Retriever`, `EmbeddingRetriever`, `MultiModalRetriever`,
  /// `Ranker`, `Generator`, `Reader`, `PromptNode`, `WebSearch`,
  /// `RouteOnAnswer`, `JoinDocuments`, `DocumentSplitter`,
  /// `DocumentJoiner`, `EmbeddingComponent`.
  final String? componentKind;

  /// `InMemory`, `Elasticsearch`, `OpenSearch`, `Weaviate`, `Pinecone`,
  /// `Qdrant`, `Milvus`, `Chroma`, `MongoDBAtlas`, `Pgvector`,
  /// `AstraDB`, `Vespa`, `Marqo`.
  final String? docStoreKind;

  final int? documentCount;

  final int? queryLength;
  final int? topK;
  final int? retrievedCount;
  final double? scoreThreshold;
  final double? minScore;
  final double? maxScore;

  final String? generatorProvider;
  final String? generatorModel;

  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  /// Pipeline loop bound (Haystack 2.x `max_loops_allowed`).
  final int? maxLoops;
  final int? loopCount;

  /// Number of edges in the resolved pipeline graph.
  final int? connectionCount;

  /// deepset Cloud workspace name (if served via deepset Cloud).
  final String? deepsetCloudWorkspace;

  /// `pipeline_validation_failed`, `component_error`, `generator_error`,
  /// `retriever_error`, `prompt_too_long`, `max_loops_exceeded`,
  /// `document_store_unavailable`.
  final String? errorKind;
  final String? errorMessage;
}

class HaystackCallResult<T> {
  const HaystackCallResult({required this.value, this.result});
  final T value;
  final HaystackResult? result;
}

/// Wraps a Haystack call in a CLIENT span. [operation] is one of
/// `pipeline.run`, `pipeline.runComponent`, `pipeline.connect`,
/// `pipeline.addComponent`, `pipeline.removeComponent`,
/// `pipeline.dumpYaml`, `pipeline.loadYaml`,
/// `documentStore.writeDocuments`, `documentStore.filterDocuments`,
/// `documentStore.deleteDocuments`, `documentStore.countDocuments`,
/// `documentStore.embedDocuments`, `generator.run`, `retriever.run`,
/// `ranker.run`, `splitter.run`, `joiner.run`, `evaluator.run`.
Future<T> tracedHaystack<T>({
  required String operation,
  required Future<HaystackCallResult<T>> Function() invoke,
}) async {
  if (haystackInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'haystack',
    'rpc.method': operation,
    'haystack.operation': operation,
  };

  final span = _tracer().startSpan(
    'haystack $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final res = r.result!;
      final extras = <Attribute<Object>>[];
      if (res.pipelineName != null) {
        extras.add(OTel.attributeString(
          'haystack.pipeline.name',
          res.pipelineName!,
        ));
      }
      if (res.componentName != null) {
        extras.add(OTel.attributeString(
          'haystack.component.name',
          res.componentName!,
        ));
      }
      if (res.componentKind != null) {
        extras.add(OTel.attributeString(
          'haystack.component.kind',
          res.componentKind!,
        ));
      }
      if (res.docStoreKind != null) {
        extras.add(OTel.attributeString(
          'haystack.document_store.kind',
          res.docStoreKind!,
        ));
      }
      if (res.documentCount != null) {
        extras.add(OTel.attributeInt(
          'haystack.document_store.count',
          res.documentCount!,
        ));
      }
      if (res.queryLength != null) {
        extras.add(OTel.attributeInt(
          'haystack.query.length',
          res.queryLength!,
        ));
      }
      if (res.topK != null) {
        extras.add(OTel.attributeInt('haystack.retriever.top_k', res.topK!));
      }
      if (res.retrievedCount != null) {
        extras.add(OTel.attributeInt(
          'haystack.retriever.retrieved_count',
          res.retrievedCount!,
        ));
      }
      if (res.scoreThreshold != null) {
        extras.add(OTel.attributeDouble(
          'haystack.retriever.score_threshold',
          res.scoreThreshold!,
        ));
      }
      if (res.minScore != null) {
        extras.add(OTel.attributeDouble(
          'haystack.retriever.min_score',
          res.minScore!,
        ));
      }
      if (res.maxScore != null) {
        extras.add(OTel.attributeDouble(
          'haystack.retriever.max_score',
          res.maxScore!,
        ));
      }
      if (res.generatorProvider != null) {
        extras.add(OTel.attributeString(
          'haystack.generator.provider',
          res.generatorProvider!,
        ));
      }
      if (res.generatorModel != null) {
        extras.add(OTel.attributeString(
          'haystack.generator.model',
          res.generatorModel!,
        ));
      }
      if (res.promptTokens != null) {
        extras.add(OTel.attributeInt(
          'haystack.usage.prompt_tokens',
          res.promptTokens!,
        ));
      }
      if (res.completionTokens != null) {
        extras.add(OTel.attributeInt(
          'haystack.usage.completion_tokens',
          res.completionTokens!,
        ));
      }
      if (res.totalTokens != null) {
        extras.add(OTel.attributeInt(
          'haystack.usage.total_tokens',
          res.totalTokens!,
        ));
      }
      if (res.maxLoops != null) {
        extras.add(OTel.attributeInt(
          'haystack.pipeline.max_loops',
          res.maxLoops!,
        ));
      }
      if (res.loopCount != null) {
        extras.add(OTel.attributeInt(
          'haystack.pipeline.loop_count',
          res.loopCount!,
        ));
      }
      if (res.connectionCount != null) {
        extras.add(OTel.attributeInt(
          'haystack.pipeline.connections',
          res.connectionCount!,
        ));
      }
      if (res.deepsetCloudWorkspace != null) {
        extras.add(OTel.attributeString(
          'haystack.deepset_cloud.workspace',
          res.deepsetCloudWorkspace!,
        ));
      }
      if (res.errorKind != null) {
        extras.add(OTel.attributeString(
          'haystack.error.kind',
          res.errorKind!,
        ));
        span.setStatus(SpanStatusCode.Error, 'Haystack ${res.errorKind}');
      }
      if (res.errorMessage != null) {
        extras.add(OTel.attributeString(
          'haystack.error.message',
          res.errorMessage!,
        ));
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
