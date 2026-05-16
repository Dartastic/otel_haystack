// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_haystack/otel_haystack.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_haystack-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('pipeline.run records doc store + components + tokens', () async {
    await tracedHaystack<String>(
      operation: 'pipeline.run',
      invoke: () async => const HaystackCallResult(
        value: 'ok',
        result: HaystackResult(
          pipelineName: 'rag_v1',
          docStoreKind: 'Weaviate',
          documentCount: 12000,
          topK: 10,
          retrievedCount: 10,
          maxScore: 0.88,
          generatorProvider: 'openai',
          generatorModel: 'gpt-4o-mini',
          totalTokens: 1842,
          connectionCount: 6,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('haystack pipeline.run')!);
    expect(a['haystack.document_store.kind'], 'Weaviate');
    expect(a['haystack.retriever.retrieved_count'], 10);
    expect(a['haystack.usage.total_tokens'], 1842);
  });

  test('max_loops_exceeded sets span error', () async {
    await tracedHaystack<String>(
      operation: 'pipeline.run',
      invoke: () async => const HaystackCallResult(
        value: 'ok',
        result: HaystackResult(
          errorKind: 'max_loops_exceeded',
          maxLoops: 5,
          loopCount: 5,
        ),
      ),
    );
    expect(
      spans.findSpanByName('haystack pipeline.run')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutHaystackInstrumentationAsync(() async {
      await tracedHaystack<String>(
        operation: 'documentStore.writeDocuments',
        invoke: () async => const HaystackCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('haystack '), isEmpty);
  });
}
