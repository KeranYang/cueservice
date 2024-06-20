// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go github.com/numaproj/numaflow/pkg/apis/numaflow/v1alpha1

package v1alpha1

import metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

// +kubebuilder:validation:Enum="";Running;Succeeded;Failed;Pausing;Paused;Deleting
#PipelinePhase: string // #enumPipelinePhase

#enumPipelinePhase:
	#PipelinePhaseUnknown |
	#PipelinePhaseRunning |
	#PipelinePhaseSucceeded |
	#PipelinePhaseFailed |
	#PipelinePhasePausing |
	#PipelinePhasePaused |
	#PipelinePhaseDeleting

#PipelinePhaseUnknown:   #PipelinePhase & ""
#PipelinePhaseRunning:   #PipelinePhase & "Running"
#PipelinePhaseSucceeded: #PipelinePhase & "Succeeded"
#PipelinePhaseFailed:    #PipelinePhase & "Failed"
#PipelinePhasePausing:   #PipelinePhase & "Pausing"
#PipelinePhasePaused:    #PipelinePhase & "Paused"
#PipelinePhaseDeleting:  #PipelinePhase & "Deleting"

// PipelineConditionConfigured has the status True when the Pipeline
// has valid configuration.
#PipelineConditionConfigured: #ConditionType & "Configured"

// PipelineConditionDeployed has the status True when the Pipeline
// has its Vertices and Jobs created.
#PipelineConditionDeployed: #ConditionType & "Deployed"

// +genclient
// +kubebuilder:object:root=true
// +kubebuilder:resource:shortName=pl
// +kubebuilder:subresource:status
// +kubebuilder:printcolumn:name="Phase",type=string,JSONPath=`.status.phase`
// +kubebuilder:printcolumn:name="Message",type=string,JSONPath=`.status.message`
// +kubebuilder:printcolumn:name="Vertices",type=integer,JSONPath=`.status.vertexCount`
// +kubebuilder:printcolumn:name="Sources",type=integer,JSONPath=`.status.sourceCount`,priority=10
// +kubebuilder:printcolumn:name="Sinks",type=integer,JSONPath=`.status.sinkCount`,priority=10
// +kubebuilder:printcolumn:name="UDFs",type=integer,JSONPath=`.status.udfCount`,priority=10
// +kubebuilder:printcolumn:name="Age",type=date,JSONPath=`.metadata.creationTimestamp`
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
// +k8s:openapi-gen=true
#Pipeline: {
	metav1.#TypeMeta
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)
	spec:      #PipelineSpec      @go(Spec) @protobuf(2,bytes,opt)

	// +optional
	status?: #PipelineStatus @go(Status) @protobuf(3,bytes,opt)
}

#Lifecycle: {
	// DeleteGracePeriodSeconds used to delete pipeline gracefully
	// +kubebuilder:default=30
	// +optional
	deleteGracePeriodSeconds?: null | int32 @go(DeleteGracePeriodSeconds,*int32) @protobuf(1,varint,opt)

	// DesiredPhase used to bring the pipeline from current phase to desired phase
	// +kubebuilder:default=Running
	// +optional
	desiredPhase?: #PipelinePhase @go(DesiredPhase) @protobuf(2,bytes,opt)

	// PauseGracePeriodSeconds used to pause pipeline gracefully
	// +kubebuilder:default=30
	// +optional
	pauseGracePeriodSeconds?: null | int32 @go(PauseGracePeriodSeconds,*int32) @protobuf(3,varint,opt)
}

#PipelineSpec: {
	// +optional
	interStepBufferServiceName?: string @go(InterStepBufferServiceName) @protobuf(1,bytes,opt)

	// +patchStrategy=merge
	// +patchMergeKey=name
	vertices?: [...#AbstractVertex] @go(Vertices,[]AbstractVertex) @protobuf(2,bytes,rep)

	// Edges define the relationships between vertices
	edges?: [...#Edge] @go(Edges,[]Edge) @protobuf(3,bytes,rep)

	// Lifecycle define the Lifecycle properties
	// +kubebuilder:default={"deleteGracePeriodSeconds": 30, "desiredPhase": Running, "pauseGracePeriodSeconds": 30}
	// +optional
	lifecycle?: #Lifecycle @go(Lifecycle) @protobuf(4,bytes,opt)

	// Limits define the limitations such as buffer read batch size for all the vertices of a pipeline, they could be overridden by each vertex's settings
	// +kubebuilder:default={"readBatchSize": 500, "bufferMaxLength": 30000, "bufferUsageLimit": 80}
	// +optional
	limits?: null | #PipelineLimits @go(Limits,*PipelineLimits) @protobuf(5,bytes,opt)

	// Watermark enables watermark progression across the entire pipeline.
	// +kubebuilder:default={"disabled": false}
	// +optional
	watermark?: #Watermark @go(Watermark) @protobuf(6,bytes,opt)

	// Templates are used to customize additional kubernetes resources required for the Pipeline
	// +optional
	templates?: null | #Templates @go(Templates,*Templates) @protobuf(7,bytes,opt)

	// SideInputs defines the Side Inputs of a pipeline.
	// +optional
	sideInputs?: [...#SideInput] @go(SideInputs,[]SideInput) @protobuf(8,bytes,rep)
}

#Watermark: {
	// Disabled toggles the watermark propagation, defaults to false.
	// +kubebuilder:default=false
	// +optional
	disabled?: bool @go(Disabled) @protobuf(1,bytes,opt)

	// Maximum delay allowed for watermark calculation, defaults to "0s", which means no delay.
	// +kubebuilder:default="0s"
	// +optional
	maxDelay?: null | metav1.#Duration @go(MaxDelay,*metav1.Duration) @protobuf(2,bytes,opt)

	// IdleSource defines the idle watermark properties, it could be configured in case source is idling.
	// +optional
	idleSource?: null | #IdleSource @go(IdleSource,*IdleSource) @protobuf(3,bytes,opt)
}

#IdleSource: {
	// Threshold is the duration after which a source is marked as Idle due to lack of data.
	// Ex: If watermark found to be idle after the Threshold duration then the watermark is progressed by `IncrementBy`.
	threshold?: null | metav1.#Duration @go(Threshold,*metav1.Duration) @protobuf(1,bytes,opt)

	// StepInterval is the duration between the subsequent increment of the watermark as long the source remains Idle.
	// The default value is 0s which means that once we detect idle source, we will be incrementing the watermark by
	// `IncrementBy` for time we detect that we source is empty (in other words, this will be a very frequent update).
	// +kubebuilder:default="0s"
	// +optional
	stepInterval?: null | metav1.#Duration @go(StepInterval,*metav1.Duration) @protobuf(2,bytes,opt)

	// IncrementBy is the duration to be added to the current watermark to progress the watermark when source is idling.
	incrementBy?: null | metav1.#Duration @go(IncrementBy,*metav1.Duration) @protobuf(3,bytes,opt)
}

#Templates: {
	// DaemonTemplate is used to customize the Daemon Deployment.
	// +optional
	daemon?: null | #DaemonTemplate @go(DaemonTemplate,*DaemonTemplate) @protobuf(1,bytes,opt)

	// JobTemplate is used to customize Jobs.
	// +optional
	job?: null | #JobTemplate @go(JobTemplate,*JobTemplate) @protobuf(2,bytes,opt)

	// SideInputsManagerTemplate is used to customize the Side Inputs Manager.
	// +optional
	sideInputsManager?: null | #SideInputsManagerTemplate @go(SideInputsManagerTemplate,*SideInputsManagerTemplate) @protobuf(3,bytes,opt)

	// VertexTemplate is used to customize the vertices of the pipeline.
	// +optional
	vertex?: null | #VertexTemplate @go(VertexTemplate,*VertexTemplate) @protobuf(4,bytes,opt)
}

#PipelineLimits: {
	// Read batch size for all the vertices in the pipeline, can be overridden by the vertex's limit settings.
	// +kubebuilder:default=500
	// +optional
	readBatchSize?: null | uint64 @go(ReadBatchSize,*uint64) @protobuf(1,varint,opt)

	// BufferMaxLength is used to define the max length of a buffer.
	// Only applies to UDF and Source vertices as only they do buffer write.
	// It can be overridden by the settings in vertex limits.
	// +kubebuilder:default=30000
	// +optional
	bufferMaxLength?: null | uint64 @go(BufferMaxLength,*uint64) @protobuf(2,varint,opt)

	// BufferUsageLimit is used to define the percentage of the buffer usage limit, a valid value should be less than 100, for example, 85.
	// Only applies to UDF and Source vertices as only they do buffer write.
	// It will be overridden by the settings in vertex limits.
	// +kubebuilder:default=80
	// +optional
	bufferUsageLimit?: null | uint32 @go(BufferUsageLimit,*uint32) @protobuf(3,varint,opt)

	// Read timeout for all the vertices in the pipeline, can be overridden by the vertex's limit settings
	// +kubebuilder:default= "1s"
	// +optional
	readTimeout?: null | metav1.#Duration @go(ReadTimeout,*metav1.Duration) @protobuf(4,bytes,opt)
}

#PipelineStatus: {
	#Status
	phase?:       #PipelinePhase @go(Phase) @protobuf(2,bytes,opt,casttype=PipelinePhase)
	message?:     string         @go(Message) @protobuf(3,bytes,opt)
	lastUpdated?: metav1.#Time   @go(LastUpdated) @protobuf(4,bytes,opt)
	vertexCount?: null | uint32  @go(VertexCount,*uint32) @protobuf(5,varint,opt)
	sourceCount?: null | uint32  @go(SourceCount,*uint32) @protobuf(6,varint,opt)
	sinkCount?:   null | uint32  @go(SinkCount,*uint32) @protobuf(7,varint,opt)
	udfCount?:    null | uint32  @go(UDFCount,*uint32) @protobuf(8,varint,opt)
}

// +kubebuilder:object:root=true
// +k8s:deepcopy-gen:interfaces=k8s.io/apimachinery/pkg/runtime.Object
#PipelineList: {
	metav1.#TypeMeta
	metadata?: metav1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)
	items: [...#Pipeline] @go(Items,[]Pipeline) @protobuf(2,bytes,rep)
}
